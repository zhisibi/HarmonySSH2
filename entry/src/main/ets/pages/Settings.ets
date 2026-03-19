import router from '@ohos.router';
import { ApiService } from '../services/ApiService';
import { FlexAlign } from '@ohos.arkui.node';

@Entry
@Component
struct Settings {
  @State action: string = '';
  @State isLoading: boolean = false;
  @State message: string = '';
  @State showMessage: boolean = false;

  // 修改密码
  @State currentPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, any>;
    if (params && params.action) {
      this.action = params.action;
    }
  }

  // 修改密码
  async changePassword() {
    if (!this.currentPassword || !this.newPassword) {
      this.showMsg('请填写完整');
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      this.showMsg('两次密码不一致');
      return;
    }

    this.isLoading = true;
    try {
      const response = await fetch(`${ApiService.getWebSocketUrl().replace('ws://', 'http://').replace('/ssh', '')}/api/admin/password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${ApiService.getToken()}`
        },
        body: JSON.stringify({
          currentPassword: this.currentPassword,
          newPassword: this.newPassword
        })
      });
      const result = await response.json();
      if (result.success) {
        this.showMsg('密码修改成功');
        this.currentPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
      } else {
        this.showMsg(result.message || '修改失败');
      }
    } catch (e) {
      this.showMsg('网络错误');
    }
    this.isLoading = false;
  }

  // 数据备份
  async backupData() {
    this.isLoading = true;
    try {
      const servers = await ApiService.getServers();
      const backupData = {
        version: '1.0',
        timestamp: new Date().toISOString(),
        servers: servers
      };
      
      // 触发下载（简化：显示 JSON）
      const jsonStr = JSON.stringify(backupData, null, 2);
      this.showMsg(`备份数据: ${servers.length} 个服务器配置`);
      console.log('备份数据:', jsonStr);
    } catch (e) {
      this.showMsg('备份失败');
    }
    this.isLoading = false;
  }

  // 数据恢复
  async restoreData() {
    this.showMsg('请在文件管理器中选择备份文件进行恢复');
  }

  showMsg(msg: string) {
    this.message = msg;
    this.showMessage = true;
    setTimeout(() => {
      this.showMessage = false;
    }, 3000);
  }

  build() {
    Column() {
      // 顶部导航
      Row({ space: 12 }) {
        Button('返回')
          .backBtnStyle()
          .onClick(() => router.back())

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')

        Blank()
      }
      .navStyle()

      Scroll() {
        Column({ space: 20 }) {
          if (this.action === 'password') {
            // 修改密码
            this.renderChangePassword();
          } else if (this.action === 'backup') {
            // 数据备份
            this.renderBackup();
          } else if (this.action === 'restore') {
            // 数据恢复
            this.renderRestore();
          } else {
            // 默认设置菜单
            this.renderMainMenu();
          }
        }
        .padding(20)
      }
    }
    .pageStyle()

    // 消息提示
    if (this.showMessage) {
      Column() {
        Text(this.message)
          .fontSize(14)
          .fontColor('#fff')
      }
      .toastStyle()
    }
  }

  @Builder
  renderMainMenu() {
    Column({ space: 12 }) {
      this.MenuItem('修改密码', '🔐', () => {
        router.pushUrl({ url: 'pages/Settings', params: { action: 'password' } });
      })
      this.MenuItem('数据备份', '📤', () => {
        router.pushUrl({ url: 'pages/Settings', params: { action: 'backup' } });
      })
      this.MenuItem('数据恢复', '📥', () => {
        router.pushUrl({ url: 'pages/Settings', params: { action: 'restore' } });
      })
      this.MenuItem('退出登录', '🚪', () => {
        ApiService.logout();
        router.replaceUrl({ url: 'pages/Login' });
      }, '#dc2626')
    }
  }

  @Builder
  renderChangePassword() {
    Column({ space: 16 }) {
      Text('修改管理员密码')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      Text('当前密码')
        .labelStyle()
      TextInput({ placeholder: '请输入当前密码', text: this.currentPassword })
        .inputStyle()
        .type(InputType.Password)
        .onChange((v) => this.currentPassword = v)

      Text('新密码')
        .labelStyle()
      TextInput({ placeholder: '请输入新密码', text: this.newPassword })
        .inputStyle()
        .type(InputType.Password)
        .onChange((v) => this.newPassword = v)

      Text('确认新密码')
        .labelStyle()
      TextInput({ placeholder: '请再次输入新密码', text: this.confirmPassword })
        .inputStyle()
        .type(InputType.Password)
        .onChange((v) => this.confirmPassword = v)

      Button('确认修改', { type: ButtonType.Capsule })
        .saveBtnStyle()
        .enabled(!this.isLoading)
        .margin({ top: 20 })
        .onClick(() => this.changePassword())
    }
  }

  @Builder
  renderBackup() {
    Column({ space: 16 }) {
      Text('数据备份')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      Text('将服务器配置导出为备份文件，便于迁移或恢复。')
        .fontSize(14)
        .fontColor('#6b7280')

      Button('开始备份', { type: ButtonType.Capsule })
        .saveBtnStyle()
        .enabled(!this.isLoading)
        .onClick(() => this.backupData())
    }
  }

  @Builder
  renderRestore() {
    Column({ space: 16 }) {
      Text('数据恢复')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 10 })

      Text('从备份文件恢复服务器配置。注意：这将覆盖现有配置。')
        .fontSize(14)
        .fontColor('#6b7280')

      Button('选择备份文件', { type: ButtonType.Capsule })
        .saveBtnStyle()
        .onClick(() => this.restoreData())
    }
  }

  @Builder
  MenuItem(title: string, icon: string, onClick: () => void, color?: string) {
    Row({ space: 12 }) {
      Text(icon)
        .fontSize(20)
      Text(title)
        .fontSize(16)
        .fontColor(color || '#111827')
      Blank()
      Text('>')
        .fontSize(16)
        .fontColor('#9ca3af')
    }
    .menuItemStyle()
    .onClick(onClick)
  }
}

// 样式
@Styles
function pageStyle() {
  .width('100%')
  .height('100%')
  .backgroundColor('#f5f7fb')
}

@Styles
function navStyle() {
  .width('100%')
  .height(60)
  .backgroundColor('#111827')
  .padding({ left: 16, right: 24 })
  .alignItems(VerticalAlign.Center)
}

@Styles
function backBtnStyle() {
  .backgroundColor('transparent')
  .fontColor('#fff')
  .fontSize(16)
}

@Styles
function menuItemStyle() {
  .width('100%')
  .padding(16)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#e5e7eb', radius: 12 })
}

@Styles
function labelStyle() {
  .fontSize(14)
  .fontColor('#374151')
  .margin({ bottom: 6 })
}

@Styles
function inputStyle() {
  .height(50)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#d1d5db', radius: 10 })
  .padding({ left: 12, right: 12 })
  .fontSize(16)
}

@Styles
function saveBtnStyle() {
  .width('100%')
  .height(50)
  .backgroundColor('#667eea')
  .fontSize(16)
  .fontColor('#fff')
}

@Styles
function toastStyle() {
  .position({ x: 30, bottom: 100 })
  .padding(12)
  .backgroundColor('rgba(0,0,0,0.7)')
  .border({ radius: 8 })
}
