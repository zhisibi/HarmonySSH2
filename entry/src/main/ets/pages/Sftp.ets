import router from '@ohos.router';
import { ApiService, Server, SftpFile } from '../services/ApiService';
import { FlexAlign, VerticalAlign, HorizontalAlign } from '@ohos.arkui.node';

@Entry
@Component
struct Sftp {
  @State server: Server = { name: '', host: '', port: 22, username: '', authType: 'password' };
  @State currentPath: string = '/';
  @State files: SftpFile[] = [];
  @State isLoading: boolean = false;
  @State isUploading: boolean = false;
  @State breadcrumb: string[] = ['/'];
  @State selectedFile: SftpFile | null = null;
  @State showActions: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, any>;
    if (params && params.server) {
      this.server = params.server;
      this.loadFiles();
    }
  }

  async loadFiles() {
    if (!this.server.id) return;
    
    this.isLoading = true;
    this.files = await ApiService.sftpList(this.server.id, this.currentPath);
    this.isLoading = false;
  }

  // 进入目录
  async enterDirectory(file: SftpFile) {
    if (file.type === 'directory') {
      this.currentPath = this.currentPath === '/' ? `/${file.name}` : `${this.currentPath}/${file.name}`;
      this.updateBreadcrumb();
      await this.loadFiles();
    } else {
      // 点击文件 - 预览或下载
      this.selectedFile = file;
    }
  }

  // 返回上级目录
  async goUp() {
    if (this.currentPath === '/') return;
    
    const parts = this.currentPath.split('/');
    parts.pop();
    this.currentPath = parts.join('/') || '/';
    this.updateBreadcrumb();
    await this.loadFiles();
  }

  // 更新面包屑
  updateBreadcrumb() {
    if (this.currentPath === '/') {
      this.breadcrumb = ['/'];
    } else {
      this.breadcrumb = ['/'];
      const parts = this.currentPath.split('/').filter(p => p);
      let path = '';
      for (const part of parts) {
        path += '/' + part;
        this.breadcrumb.push(path);
      }
    }
  }

  // 面包屑点击
  async onBreadcrumbClick(path: string) {
    this.currentPath = path;
    this.updateBreadcrumb();
    await this.loadFiles();
  }

  // 新建文件夹
  async createFolder() {
    // 简单实现：使用 prompt 对话框
    // 鸿蒙原生需要自定义弹窗，这里用简单方式
    const folderName = 'new_folder'; // 可以改为从输入框获取
    if (!this.server.id) return;
    
    const newPath = this.currentPath === '/' ? `/${folderName}` : `${this.currentPath}/${folderName}`;
    const result = await ApiService.sftpMkdir(this.server.id, newPath);
    if (result.success) {
      this.loadFiles();
    }
  }

  // 删除文件
  async deleteFile(file: SftpFile) {
    if (!this.server.id) return;
    
    const result = await ApiService.sftpDelete(this.server.id, file.name, file.type === 'directory' ? 'directory' : 'file');
    if (result.success) {
      this.showActions = false;
      this.loadFiles();
    }
  }

  // 重命名
  async renameFile(file: SftpFile) {
    // 简化实现
    this.showActions = false;
  }

  // 获取文件图标
  getFileIcon(file: SftpFile): string {
    if (file.type === 'directory') return '📁';
    if (file.type === 'link') return '🔗';
    const ext = file.name.split('.').pop()?.toLowerCase();
    switch (ext) {
      case 'txt': case 'md': case 'log': return '📄';
      case 'jpg': case 'jpeg': case 'png': case 'gif': case 'svg': return '🖼️';
      case 'mp3': case 'wav': case 'ogg': return '🎵';
      case 'mp4': case 'avi': case 'mov': return '🎬';
      case 'zip': case 'tar': case 'gz': case 'rar': return '📦';
      case 'js': case 'ts': case 'py': case 'java': case 'go': return '💻';
      case 'json': case 'xml': case 'yaml': case 'yml': return '⚙️';
      default: return '📄';
    }
  }

  // 格式化文件大小
  formatSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  // 格式化时间
  formatTime(timestamp: number): string {
    const date = new Date(timestamp * 1000);
    return date.toLocaleDateString();
  }

  build() {
    Column() {
      // 顶部导航
      Row({ space: 12 }) {
        Button('返回')
          .backgroundColor('transparent')
          .fontColor('#fff')
          .fontSize(16)
          .onClick(() => router.back())

        Column({ space: 2 }) {
          Text(this.server.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
          Text('SFTP 文件管理')
            .fontSize(12)
            .fontColor('#9ca3af')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('上级')
          .backgroundColor('#f59e0b')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ left: 10, right: 10 })
          .height(32)
          .onClick(() => this.goUp())
      }
      .width('100%')
      .height(60)
      .backgroundColor('#111827')
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 面包屑导航
      Scroll() {
        Row({ space: 4 }) {
          ForEach(this.breadcrumb, (path: string, index: number) => {
            Row({ space: 4 }) {
              Text(path === '/' ? '根目录' : path.split('/').pop())
                .fontSize(14)
                .fontColor(index === this.breadcrumb.length - 1 ? '#667eea' : '#6b7280')
                .onClick(() => this.onBreadcrumbClick(path))
              
              if (index < this.breadcrumb.length - 1) {
                Text('>')
                  .fontSize(14)
                  .fontColor('#9ca3af')
              }
            }
          })
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#fff')
      .border({ width: 1, color: '#e5e7eb' })

      // 工具栏
      Row({ space: 8 }) {
        Button('新建文件夹')
          .backgroundColor('#e5e7eb')
          .fontColor('#374151')
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => this.createFolder())
        
        Button('刷新')
          .backgroundColor('#e5e7eb')
          .fontColor('#374151')
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => this.loadFiles())
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#fff')

      // 文件列表
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.files.length === 0) {
        Column() {
          Text('空目录')
            .fontSize(16)
            .fontColor('#666')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.files, (file: SftpFile) => {
            ListItem() {
              Row({ space: 12 }) {
                Text(this.getFileIcon(file))
                  .fontSize(24)
                
                Column({ space: 4 }) {
                  Text(file.name)
                    .fontSize(16)
                    .fontColor('#111827')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(this.formatSize(file.size))
                    .fontSize(12)
                    .fontColor('#6b7280')
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(this.formatTime(file.modifyTime))
                  .fontSize(12)
                  .fontColor('#9ca3af')
              }
              .width('100%')
              .padding(12)
              .border({ width: 1, color: '#f3f4f6', radius: 0 })
              .onClick(() => this.enterDirectory(file))
              .onLongPress(() => {
                this.selectedFile = file;
                this.showActions = true;
              })
            }
          })
        }
        .width('100%')
        .backgroundColor('#fff')
        .layoutWeight(1)
      }
    
    // 操作菜单
    if (this.showActions && this.selectedFile) {
      Column() {
        Blank()
          .onClick(() => this.showActions = false)
        
        Column() {
          Text(this.selectedFile.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 16 })
          
          if (!this.selectedFile.isDirectory) {
            Button('下载')
              .width('100%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#667eea')
              .fontColor('#fff')
              .fontSize(14)
              .onClick(() => this.downloadFile())
          }
          
          Button('重命名')
            .width('100%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#667eea')
              .fontColor('#fff')
              .fontSize(14)
            .onClick(() => this.renameFile(this.selectedFile!))
          
          Button('删除', { type: ButtonType.Capsule })
            .width('100%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#dc2626')
              .fontColor('#fff')
              .fontSize(14)
            .onClick(() => this.deleteFile(this.selectedFile!))
          
          Button('取消')
            .width('100%')
              .height(44)
              .margin({ bottom: 8 })
              .backgroundColor('#6b7280')
              .fontColor('#fff')
              .fontSize(14)
            .margin({ top: 8 })
            .onClick(() => this.showActions = false)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#fff')
        .border({ width: 1, color: '#e5e7eb', radius: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.3)')
      .position({ left: 0, top: 0 })
    }
  }
  .width('100%')
  .height('100%')
  .backgroundColor('#f5f7fb')

  downloadFile() {
    if (!this.server.id || !this.selectedFile) return;
    const url = ApiService.getSftpDownloadUrl(this.server.id, this.selectedFile.name);
    // 鸿蒙下载需要在 Ability 中实现，这里简单提示
    console.log('下载:', url);
    this.showActions = false;
  }
}

