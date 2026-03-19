// API 服务 - 对接 WebSSH 后端

// 后端地址配置
const BASE_URL = 'http://192.168.100.20:3000';
const WS_URL = 'ws://192.168.100.20:3000';

// 存储
const TOKEN_KEY = 'webssh_token';

export class ApiService {
  private static token: string = '';

  // 设置 Token
  static setToken(token: string): void {
    this.token = token;
  }

  // 获取 Token
  static getToken(): string {
    return this.token;
  }

  // 清除 Token
  static clearToken(): void {
    this.token = '';
  }

  // 通用请求头
  private static getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    return headers;
  }

  // 登录
  static async login(username: string, password: string): Promise<{ success: boolean; token?: string; message?: string }> {
    try {
      const response = await fetch(`${BASE_URL}/api/login`, {
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

  // 登出
  static async logout(): Promise<void> {
    try {
      await fetch(`${BASE_URL}/api/logout`, {
        method: 'POST',
        headers: this.getHeaders()
      });
    } catch (e) {
      console.error('[ApiService] 登出失败:', e);
    }
    this.clearToken();
  }

  // 获取服务器列表
  static async getServers(): Promise<Server[]> {
    try {
      const response = await fetch(`${BASE_URL}/api/servers`, {
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

  // 添加服务器
  static async addServer(server: Server): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${BASE_URL}/api/servers`, {
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

  // 更新服务器
  static async updateServer(id: number, server: Server): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${BASE_URL}/api/servers/${id}`, {
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

  // 删除服务器
  static async deleteServer(id: number): Promise<{ success: boolean; message?: string }> {
    try {
      const response = await fetch(`${BASE_URL}/api/servers/${id}`, {
        method: 'DELETE',
        headers: this.getHeaders()
      });
      return await response.json();
    } catch (error) {
      console.error('[ApiService] 删除服务器失败:', error);
      return { success: false, message: '网络错误' };
    }
  }

  // SFTP: 列出目录
  static async sftpList(serverId: number, path: string): Promise<SftpFile[]> {
    try {
      const response = await fetch(`${BASE_URL}/api/sftp/list?serverId=${serverId}&path=${encodeURIComponent(path)}`, {
        headers: this.getHeaders()
      });
      const result = await response.json();
      return result.files || [];
    } catch (error) {
      console.error('[ApiService] SFTP列表失败:', error);
      return [];
    }
  }

  // SFTP: 下载文件
  static getSftpDownloadUrl(serverId: number, path: string): string {
    return `${BASE_URL}/api/sftp/download?serverId=${serverId}&path=${encodeURIComponent(path)}`;
  }

  // SFTP: 新建文件夹
  static async sftpMkdir(serverId: number, path: string, dirname: string): Promise<{ success: boolean }> {
    try {
      const response = await fetch(`${BASE_URL}/api/sftp/mkdir`, {
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

  // SFTP: 删除
  static async sftpDelete(serverId: number, targetPath: string, type: string): Promise<{ success: boolean }> {
    try {
      const response = await fetch(`${BASE_URL}/api/sftp/delete`, {
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

  // SFTP: 重命名
  static async sftpRename(serverId: number, oldPath: string, newPath: string): Promise<{ success: boolean }> {
    try {
      const response = await fetch(`${BASE_URL}/api/sftp/rename`, {
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

  // 获取 WebSocket SSH URL
  static getWebSocketSshUrl(serverId: number): string {
    const token = this.getToken();
    return `${WS_URL}/ws/ssh?serverId=${serverId}&token=${token}`;
  }

  // 获取 WebSocket SFTP URL
  static getWebSocketSftpUrl(serverId: number): string {
    const token = this.getToken();
    return `${WS_URL}/ws/sftp?serverId=${serverId}&token=${token}`;
  }

  // 获取 SFTP WebSocket URL
  static getSftpWebSocketUrl(): string {
    return `${WS_URL}/sftp`;
  }
}

// 类型定义
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
}

export interface SftpFile {
  name: string;
  type: 'directory' | 'file' | 'link';
  size: number;
  mtime: number;
  mode: string;
}
