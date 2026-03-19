// 工具函数

// 字符串转义（防止 XSS）
export function escapeHtml(str: string): string {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// 日期格式化
export function formatDate(timestamp: number): string {
  const date = new Date(timestamp * 1000);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day} ${hour}:${minute}`;
}

// 文件大小格式化
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 获取文件图标
export function getFileIcon(filename: string, isDirectory: boolean, isLink: boolean): string {
  if (isDirectory) return '📁';
  if (isLink) return '🔗';
  
  const ext = filename.split('.').pop()?.toLowerCase();
  switch (ext) {
    case 'txt': case 'md': case 'log': return '📄';
    case 'jpg': case 'jpeg': case 'png': case 'gif': case 'webp': return '🖼️';
    case 'mp3': case 'wav': case 'ogg': case 'flac': return '🎵';
    case 'mp4': case 'avi': case 'mov': case 'mkv': return '🎬';
    case 'zip': case 'tar': case 'gz': case 'rar': case '7z': return '📦';
    case 'js': case 'ts': case 'jsx': case 'tsx': return '💻';
    case 'py': case 'java': case 'go': case 'rs': return '⚙️';
    case 'json': case 'xml': case 'yaml': case 'yml': return '⚡';
    case 'pdf': return '📕';
    case 'html': case 'css': case 'scss': return '🌐';
    default: return '📄';
  }
}

// 验证 IP 地址
export function isValidIP(ip: string): boolean {
  const pattern = /^(\d{1,3}\.){3}\d{1,3}$/;
  if (!pattern.test(ip)) return false;
  const parts = ip.split('.');
  return parts.every(part => {
    const num = parseInt(part);
    return num >= 0 && num <= 255;
  });
}

// 验证端口
export function isValidPort(port: number): boolean {
  return port > 0 && port <= 65535;
}

// 防抖函数
export function debounce(fn: Function, delay: number): Function {
  let timer: number | null = null;
  return (...args: any[]) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}

// 节流函数
export function throttle(fn: Function, limit: number): Function {
  let inThrottle: boolean = false;
  return (...args: any[]) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}
