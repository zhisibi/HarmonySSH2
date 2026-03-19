import router from '@ohos.router';
import { ApiService } from '../services/ApiService';

@Entry
@Component
struct Login {
  @State baseUrl: string = 'http://192.168.100.20:3000';
  @State username: string = '';
  @State password: string = '';
  @State errorMsg: string = '';
  @State isLoading: boolean = false;

  private primaryColor: string = '#667eea';

  async doLogin() {
    if (!this.username || !this.password) {
      this.errorMsg = '请输入用户名和密码';
      return;
    }

    this.isLoading = true;
    this.errorMsg = '';

    // 设置后端地址
    ApiService.setBaseUrl(this.baseUrl);
    
    const result = await ApiService.login(this.username, this.password);

    this.isLoading = false;

    if (result.success) {
      router.replaceUrl({ url: 'pages/Home' });
    } else {
      this.errorMsg = result.message || '登录失败';
    }
  }

  build() {
    // 紫色渐变背景
    Column() {
      // 登录卡片
      Column() {
        Text('WebSSH 管理登录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ bottom: 30 })

        // 后端地址输入
        Column({ space: 8 }) {
          Text('后端地址')
            .fontSize(14)
            .fontColor('#555')
            .fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '请输入后端地址', text: this.baseUrl })
            .loginInput()
            .onChange((value) => {
              this.baseUrl = value;
              this.errorMsg = '';
            })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // 用户名输入
        Column({ space: 8 }) {
          Text('用户名')
            .fontSize(14)
            .fontColor('#555')
            .fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '请输入用户名', text: this.username })
            .loginInput()
            .onChange((value) => {
              this.username = value;
              this.errorMsg = '';
            })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })

        // 密码输入
        Column({ space: 8 }) {
          Text('密码')
            .fontSize(14)
            .fontColor('#555')
            .fontWeight(FontWeight.Medium)
          TextInput({ placeholder: '请输入密码', text: this.password })
            .loginInput()
            .type(InputType.Password)
            .onChange((value) => {
              this.password = value;
              this.errorMsg = '';
            })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 30 })

        // 登录按钮
        Button('登录', { type: ButtonType.Capsule })
          .loginBtn()
          .enabled(!this.isLoading)
          .onClick(() => this.doLogin())

        // 加载中
        if (this.isLoading) {
          Text('登录中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 20 })
        }

        // 错误提示
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#e53e3e')
            .margin({ top: 20 })
        }
      }
      .loginCard()
    }
    .loginBg()
  }
}

@Styles
function loginBg() {
  .width('100%')
  .height('100%')
  .backgroundColor('#667eea')
}

@Styles
function loginCard() {
  .width(300)
  .padding(32)
  .backgroundColor('#fff')
  .borderRadius(10)
  .shadow({ radius: 25, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 10 })
}

@Styles
function loginInput() {
  .height(48)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#ddd', radius: 5 })
  .padding({ left: 12, right: 12 })
  .fontSize(14)
}

@Styles
function loginBtn() {
  .width('100%')
  .height(48)
  .backgroundColor('#667eea')
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
}
