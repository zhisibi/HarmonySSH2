import router from '@ohos.router';
import { ApiService, Server } from '../services/ApiService';
import { VerticalAlign, HorizontalAlign } from '@ohos.arkui.node';

@Entry
@Component
struct ServerForm {
  @State server: Server = this.initServer();
  @State isEditing: boolean = false;
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  @State showPassword: boolean = false;

  initServer(): Server {
    return {
      name: '',
      host: '',
      port: 22,
      username: '',
      authType: 'password',
      password: '',
      privateKey: '',
      passphrase: '',
      tags: ''
    };
  }

  aboutToAppear() {
    const params = router.getParams() as Record<string, any>;
    if (params && params.server) {
      this.server = { ...params.server };
      this.isEditing = true;
    }
  }

  async saveServer() {
    // 验证
    if (!this.server.name || !this.server.host || !this.server.username) {
      this.errorMsg = '请填写必填项';
      return;
    }

    this.isLoading = true;
    this.errorMsg = '';

    let result;
    if (this.isEditing && this.server.id) {
      result = await ApiService.updateServer(this.server.id, this.server);
    } else {
      result = await ApiService.addServer(this.server);
    }

    this.isLoading = false;

    if (result.success) {
      router.back();
    } else {
      this.errorMsg = result.message || '保存失败';
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('返回')
          .backBtnStyle()
          .onClick(() => router.back())
        
        Text(this.isEditing ? '编辑服务器' : '添加服务器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
        
        Blank()
      }
      .navStyle()

      Scroll() {
        Column({ space: 16 }) {
          // 服务器名称
          this.FormItem('服务器名称', '必填')
          TextInput({ placeholder: '请输入服务器名称', text: this.server.name })
            .formInput()
            .onChange((v) => this.server.name = v)

          // 主机地址
          this.FormItem('主机地址', '必填')
          TextInput({ placeholder: '如 192.168.1.100 或 example.com', text: this.server.host })
            .formInput()
            .onChange((v) => this.server.host = v)

          // 端口
          this.FormItem('端口', '默认 22')
          TextInput({ placeholder: '22', text: this.server.port?.toString() || '22' })
            .formInput()
            .type(InputType.Number)
            .onChange((v) => this.server.port = parseInt(v) || 22)

          // 用户名
          this.FormItem('用户名', '必填')
          TextInput({ placeholder: '请输入用户名', text: this.server.username })
            .formInput()
            .onChange((v) => this.server.username = v)

          // 认证方式
          this.FormItem('认证方式')
          Row({ space: 12 }) {
            Radio('password').value('password').label('密码认证')
              .checked(this.server.authType === 'password')
              .onChange((v: boolean) => {
                if (v) this.server.authType = 'password';
              })
            Radio('key').value('key').label('密钥认证')
              .checked(this.server.authType === 'key')
              .onChange((v: boolean) => {
                if (v) this.server.authType = 'key';
              })
          }

          // 密码认证
          if (this.server.authType === 'password') {
            this.FormItem('密码')
            TextInput({ placeholder: '请输入密码', text: this.server.password })
              .formInput()
              .type(InputType.Password)
              .onChange((v) => this.server.password = v)
          }

          // 密钥认证
          if (this.server.authType === 'key') {
            this.FormItem('私钥', 'PEM 格式')
            TextArea({ placeholder: '粘贴私钥内容', text: this.server.privateKey })
              .formTextArea()
              .onChange((v) => this.server.privateKey = v)

            this.FormItem('密钥密码', '可选')
            TextInput({ placeholder: '如有 passphrase 请填写', text: this.server.passphrase })
              .formInput()
              .type(InputType.Password)
              .onChange((v) => this.server.passphrase = v)
          }

          // 标签
          this.FormItem('标签', '逗号分隔')
          TextInput({ placeholder: '如: 生产, 北京, Web', text: this.server.tags })
            .formInput()
            .onChange((v) => this.server.tags = v)

          // 错误提示
          if (this.errorMsg) {
            Text(this.errorMsg)
              .fontSize(14)
              .fontColor('#e53e3e')
              .margin({ top: 10 })
          }

          // 保存按钮
          Button(this.isEditing ? '保存修改' : '添加服务器', { type: ButtonType.Capsule })
            .saveBtnStyle()
            .enabled(!this.isLoading)
            .margin({ top: 20, bottom: 40 })
            .onClick(() => this.saveServer())
        }
        .padding(20)
      }
    }
    .pageStyle()
  }

  @Builder
  FormItem(label: string, tip?: string) {
    Row({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
      if (tip) {
        Text(tip)
          .fontSize(12)
          .fontColor('#9ca3af')
      }
    }
    .alignSelf(HorizontalAlign.Start)
    .margin({ top: 10, bottom: 6 })
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
function formInput() {
  .height(50)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#d1d5db', radius: 10 })
  .padding({ left: 12, right: 12 })
  .fontSize(16)
}

@Styles
function formTextArea() {
  .height(120)
  .backgroundColor('#fff')
  .border({ width: 1, color: '#d1d5db', radius: 10 })
  .padding(12)
  .fontSize(14)
}

@Styles
function saveBtnStyle() {
  .width('100%')
  .height(50)
  .backgroundColor('#10b981')
  .fontSize(18)
  .fontColor('#fff')
}
