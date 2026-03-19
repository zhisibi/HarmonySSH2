// API 服务 - 对接 WebSSH 后端

const TOKEN_KEY = 'webssh_token';
const BASE_URL_KEY = 'webssh_base_url';

export class ApiService {
  private static token: string = '';
  private static baseUrl: string = 'http://192.168.100.20:3000';
  private static wsUrl: string = 'ws://192.168.100.20:3000';

  // ====== Token ======
  static setToken(token: string): void {
    this.token = token;
  }

  static getToken(): string {
    return this.token;
  }

  static clearToken(): void {
    this.token = '';
  }

  // ====== Base URL / WS URL ======
  /**
   * 支持用户在登录页动态设置后端地址。
   * 例：http://192.168.100.20:3000
   */
  static setBaseUrl(url: string): void {
    const normalized = (url || '').trim().replace(/\/$/, '');
    if (!normalized) {
      return;
    }
    this.baseUrl = normalized;
    this.wsUrl = normalized.replace(/^http(s)?:\/\//, (m) => (m.startsWith('https') ? 'wss://' : 'ws://'));

    // TODO: 可接入 Preferences 持久化（后续需要时再做）
    // Preferences.set({ key: BASE_URL_KEY, value: this.baseUrl });
  }

  static getBaseUrl(): string {
    return this.baseUrl;
  }

  static getWsUrl(): string {
    return this.wsUrl;
  }

  // ====== HTTP helpers ======
  private static getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    return headers;
  }

  // ====== Auth ======
  static async login(username: string, password: string): Promise<{ success: boolean; token?: string; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      });
      const data = await response.json();
      if (data.success && data.token) {
        this.setToken(data.token);
      }
      return data;
    } catch (error) {
      console.error('[ApiService] 登录失败:', error);
      return { success: false, message: '网络错误，请检查服务器连接' };
    }
  }

  static async logout(): Promise<void> {
    try {
      await fetch(`${this.baseUrl}/api/logout`, {
        method: 'POST',
        headers: this.getHeaders()
      });
    } catch (e) {
      console.error('[ApiService] 登出失败:', e);
    }
    this.clearToken();
  }

  // ====== Server CRUD ======
  static async getServers(): Promise<Server[]> {
    try {
      const response = await fetch(`${this.baseUrl}/api/servers`, {
        headers: this.getHeaders()
      });
      if (response.status === 401) {
        this.clearToken();
        return [];
      }
      return await response.json();
    } catch (error) {
      console.error('[ApiService] 获取服务器列表失败:', error);
      return [];
    }
  }

  static async addServer(server: Server): Promise<{ success: boolean; message?: string; id?: number }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/servers`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify(server)
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] 添加服务器失败:', error);
      return { success: false, message: '网络错误' };
    }
  }

  static async updateServer(id: number, server: Server): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/servers/${id}`, {
        method: 'PUT',
        headers: this.getHeaders(),
        body: JSON.stringify(server)
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] 更新服务器失败:', error);
      return { success: false, message: '网络错误' };
    }
  }

  static async deleteServer(id: number): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/servers/${id}`, {
        method: 'DELETE',
        headers: this.getHeaders()
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] 删除服务器失败:', error);
      return { success: false, message: '网络错误' };
    }
  }

  // ====== SFTP ======
  static async sftpList(serverId: number, path: string): Promise<SftpFile[]> {
    try {
      const response = await fetch(`${this.baseUrl}/api/sftp/list?serverId=${serverId}&path=${encodeURIComponent(path)}`, {
        headers: this.getHeaders()
      });
      const result = await response.json();
      return result.files || [];
    } catch (error) {
      console.error('[ApiService] SFTP列表失败:', error);
      return [];
    }
  }

  static getSftpDownloadUrl(serverId: number, path: string): string {
    return `${this.baseUrl}/api/sftp/download?serverId=${serverId}&path=${encodeURIComponent(path)}`;
  }

  static async sftpMkdir(serverId: number, path: string, dirname: string): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/sftp/mkdir`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ serverId, path, dirname })
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] SFTP创建目录失败:', error);
      return { success: false };
    }
  }

  static async sftpDelete(serverId: number, targetPath: string, type: 'file' | 'directory'): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/sftp/delete`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ serverId, targetPath, type })
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] SFTP删除失败:', error);
      return { success: false };
    }
  }

  static async sftpRename(serverId: number, oldPath: string, newPath: string): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${this.baseUrl}/api/sftp/rename`, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({ serverId, oldPath, newPath })
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] SFTP重命名失败:', error);
      return { success: false };
    }
  }

  // ====== WebSocket ======
  static getWebSocketSshUrl(serverId: number): string {
    const token = this.getToken();
    return `${this.wsUrl}/ws/ssh?serverId=${serverId}&token=${token}`;
  }

  static getWebSocketSftpUrl(serverId: number): string {
    const token = this.getToken();
    return `${this.wsUrl}/ws/sftp?serverId=${serverId}&token=${token}`;
  }
}

// ====== 类型定义 ======
export interface Server {
  id?: number;
  name: string;
  host: string;
  port: number;
  username: string;
  authType: 'password' | 'key';
  password?: string;
  privateKey?: string;
  passphrase?: string;
  tags?: string;
  enabled?: boolean;
}

export interface SftpFile {
  name: string;
  type: 'directory' | 'file' | 'link';
  size: number;
  mtime: number;
  mode: string;
}
