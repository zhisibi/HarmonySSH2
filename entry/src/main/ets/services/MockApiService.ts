// Mock API Service - used to make UI runnable without network dependencies

export interface Server {
  id: number;
  name: string;
  host: string;
  port: number;
  username: string;
  authType: 'password' | 'key';
  tags: string[];
  enabled: boolean;
}

export interface SftpFile {
  name: string;
  type: 'directory' | 'file' | 'link';
  size: number;
  mtime: number;
  mode: string;
}

export class MockApiService {
  private static token: string = 'mock-token';
  private static baseUrl: string = 'http://192.168.100.20:3000';

  static setBaseUrl(url: string): void {
    this.baseUrl = url;
  }

  static getBaseUrl(): string {
    return this.baseUrl;
  }

  static getToken(): string {
    return this.token;
  }

  static async login(username: string, password: string): Promise<{ success: boolean; token?: string; message?: string }> {
    if (!username || !password) {
      return { success: false, message: '请输入用户名和密码' };
    }
    // Mock accepts admin/admin123
    if (username === 'admin' && password === 'admin123') {
      this.token = 'mock-token';
      return { success: true, token: this.token, message: '登录成功（Mock）' };
    }
    return { success: false, message: '用户名或密码错误（Mock）' };
  }

  static async logout(): Promise<void> {
    this.token = '';
  }

  static async getServers(): Promise<Server[]> {
    return [
      {
        id: 1773839813662,
        name: '在线测试',
        host: '192.168.100.20',
        port: 22,
        username: 'root',
        authType: 'password',
        tags: [],
        enabled: true
      },
      {
        id: 1773887608271,
        name: '本机',
        host: '127.0.0.1',
        port: 22,
        username: 'root',
        authType: 'password',
        tags: [],
        enabled: true
      }
    ];
  }

  static async addServer(server: Server): Promise<{ success: boolean; id?: number; message?: string }> {
    return { success: true, id: Date.now(), message: '已添加（Mock）' };
  }

  static async updateServer(id: number, server: Server): Promise<{ success: boolean; message?: string }> {
    return { success: true, message: '已更新（Mock）' };
  }

  static async deleteServer(id: number): Promise<{ success: boolean; message?: string }> {
    return { success: true, message: '已删除（Mock）' };
  }

  static async sftpList(serverId: number, path: string): Promise<SftpFile[]> {
    const now = Math.floor(Date.now() / 1000);
    return [
      { name: 'home', type: 'directory', size: 0, mtime: now, mode: '40755' },
      { name: 'etc', type: 'directory', size: 0, mtime: now, mode: '40755' },
      { name: 'test.txt', type: 'file', size: 1024, mtime: now, mode: '100644' },
      { name: 'link', type: 'link', size: 7, mtime: now, mode: '120777' }
    ];
  }

  static getSftpDownloadUrl(serverId: number, path: string): string {
    return `${this.baseUrl}/api/sftp/download?serverId=${serverId}&path=${encodeURIComponent(path)}`;
  }
}
