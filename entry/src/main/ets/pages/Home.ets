import router from '@ohos.router';
import { ApiService, Server } from '../services/ApiService';

@Entry
@Component
struct Home {
  @State servers: Server[] = [];
  @State isLoading: boolean = true;
  @State showSettings: boolean = false;

  aboutToAppear() {
    this.loadServers();
  }

  async loadServers() {
    this.isLoading = true;
    this.servers = await ApiService.getServers();
    this.isLoading = false;
  }

  goToAddServer() {
    router.pushUrl({ url: 'pages/ServerForm' });
  }

  goToEditServer(server: Server) {
    router.pushUrl({ url: 'pages/ServerForm', params: { server } });
  }

  goToTerminal(server: Server) {
    router.pushUrl({ url: 'pages/Terminal', params: { server } });
  }

  goToSftp(server: Server) {
    router.pushUrl({ url: 'pages/Sftp', params: { server } });
  }

  async deleteServer(server: Server) {
    if (!server.id) return;
    
    try {
      const result = await ApiService.deleteServer(server.id);
      if (result.success) {
        this.loadServers();
      } else {
        console.error('删除失败:', result.message);
      }
    } catch (e) {
      console.error('删除失败:', e);
    }
  }

  async logout() {
    await ApiService.logout();
    router.replaceUrl({ url: 'pages/Login' });
  }

  build() {
    Column() {
      // 深色顶部导航
      Row() {
        Text('WebSSH 控制面板')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        
        Row({ space: 8 }) {
          Button('设置')
            .headerBtn()
            .onClick(() => this.showSettings = !this.showSettings)
          Button('退出登录')
            .headerBtn()
            .onClick(() => this.logout())
        }
      }
      .header()

      // 设置下拉菜单
      if (this.showSettings) {
        Column() {
          Text('数据备份')
            .menuItem()
            .onClick(() => {
              this.showSettings = false;
              router.pushUrl({ url: 'pages/Settings', params: { action: 'backup' } });
            })
          Text('数据恢复')
            .menuItem()
            .onClick(() => {
              this.showSettings = false;
              router.pushUrl({ url: 'pages/Settings', params: { action: 'restore' } });
            })
          Text('修改密码')
            .menuItem()
            .fontColor('#b91c1c')
            .onClick(() => {
              this.showSettings = false;
              router.pushUrl({ url: 'pages/Settings', params: { action: 'password' } });
            })
        }
        .settingsMenu()
      }

      // 内容区域
      Column() {
        // 标题栏
        Row() {
          Text('服务器列表')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
          
          Blank()
          
          Button('添加服务器')
            .addBtn()
            .onClick(() => this.goToAddServer())
        }
        .sectionHeader()

        // 加载中
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#666')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } 
        // 空状态
        else if (this.servers.length === 0) {
          Column() {
            Text('暂无服务器')
              .fontSize(16)
              .fontColor('#666')
            Text('点击"添加服务器"开始')
              .fontSize(14)
              .fontColor('#999')
              .margin({ top: 10 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } 
        // 服务器卡片网格
        else {
          Scroll() {
            Column({ space: 16 }) {
              ForEach(this.servers, (server: Server) => {
                this.ServerCard(server)
              })
            }
            .padding({ top: 16, bottom: 16 })
          }
          .layoutWeight(1)
        }
      }
      .content()
    }
    .page()
  }

  @Builder
  ServerCard(server: Server) {
    Column() {
      // 卡片头部
      Row({ space: 12 }) {
        Text('🖥️')
          .fontSize(28)
        Column({ space: 4 }) {
          Text(server.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text(`${server.username}@${server.host}:${server.port || 22}`)
            .fontSize(13)
            .fontColor('#6b7280')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .margin({ bottom: 14 })

      // 操作按钮
      Row({ space: 8 }) {
        Button('SSH')
          .cardBtn('#111827')
          .onClick(() => this.goToTerminal(server))
        
        Button('SFTP')
          .cardBtn('#4f46e5')
          .onClick(() => this.goToSftp(server))
        
        Button('编辑')
          .cardBtn('#f59e0b')
          .onClick(() => this.goToEditServer(server))
        
        Button('删除')
          .cardBtn('#dc2626')
          .onClick(() => this.deleteServer(server))
      }
    }
    .card()
  }
}

@Styles
function page() {
  .width('100%')
  .height('100%')
  .backgroundColor('#f5f7fb')
}

@Styles
function header() {
  .width('100%')
  .height(60)
  .backgroundColor('#111827')
  .padding({ left: 24, right: 24 })
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
}

@Styles
function headerBtn() {
  .backgroundColor('#374151')
  .fontColor('#fff')
  .fontSize(13)
  .padding({ left: 12, right: 12 })
  .height(34)
}

@Styles
function settingsMenu() {
  .position({ x: '55%', y: 70 })
  .width(150)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#e5e7eb', radius: 8 })
  .shadow({ radius: 10, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 5 })
}

@Styles
function menuItem() {
  .width('100%')
  .padding({ left: 14, right: 14, top: 10, bottom: 10 })
  .fontSize(13)
  .fontColor('#111827')
}

@Styles
function content() {
  .flex(1)
  .padding(24)
}

@Styles
function sectionHeader() {
  .width('100%')
  .margin({ bottom: 8 })
}

@Styles
function addBtn() {
  .backgroundColor('#10b981')
  .fontColor('#fff')
  .fontSize(14)
  .padding({ left: 14, right: 14 })
  .height(36)
}

@Styles
function card() {
  .width('100%')
  .backgroundColor('#fff')
  .border({ width: 1, color: '#e5e7eb', radius: 14 })
  .padding(16)
  .shadow({ radius: 18, color: 'rgba(0,0,0,0.04)', offsetX: 0, offsetY: 4 })
}

@Styles
function cardBtn(color: string) {
  .backgroundColor(color)
  .fontColor('#fff')
  .fontSize(14)
  .padding({ left: 14, right: 14 })
  .height(40)
  .borderRadius(10)
}
