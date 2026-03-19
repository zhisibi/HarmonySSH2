import router from '@ohos.router';
import { MockApiService, Server } from '../services/MockApiService';

type WsLike = { close: () => void } | null;
import { VerticalAlign, Alignment } from '@ohos.arkui.node';

// 简单的终端缓冲区
class TerminalBuffer {
  lines: string[] = [];
  maxLines: number = 500;

  addLine(line: string) {
    this.lines.push(line);
    if (this.lines.length > this.maxLines) {
      this.lines.shift();
    }
  }

  addText(text: string) {
    const textLines = text.split('\n');
    for (const line of textLines) {
      this.addLine(line);
    }
  }

  clear() {
    this.lines = [];
  }

  getText(): string {
    return this.lines.join('\n');
  }
}

@Entry
@Component
struct Terminal {
  @State server: Server = { name: '', host: '', port: 22, username: '', authType: 'password' };
  @State outputText: string = '';
  @State inputCommand: string = '';
  @State isConnected: boolean = false;
  @State isConnecting: boolean = false;
  @State statusText: string = '未连接';

  private buffer: TerminalBuffer = new TerminalBuffer();
  private ws: WsLike = null;
  private commandHistory: string[] = [];
  private historyIndex: number = -1;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object | undefined>;
    if (params && params.server) {
      this.server = params.server;
      this.connect();
    }
  }

  aboutToDisappear() {
    this.disconnect();
  }

  connect() {
    if (this.isConnecting || this.isConnected) return;

    this.isConnecting = true;
    this.statusText = '连接中...';
    this.buffer.addLine(`正在连接 ${this.server.username}@${this.server.host}...`);

    // Mock 模式：不建立真实 WebSocket，仅模拟连接成功
    this.isConnected = true;
    this.isConnecting = false;
    this.statusText = '已连接（Mock）';
    this.buffer.addLine(`已连接到 ${this.server.host}（Mock）`);
    this.updateOutput();
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.isConnected = false;
  }

  sendCommand() {
    if (!this.isConnected || !this.inputCommand.trim()) return;

    const cmd = this.inputCommand.trim();
    this.buffer.addLine(`$ ${cmd}`);
    this.commandHistory.push(cmd);
    this.historyIndex = this.commandHistory.length;

    // Mock 模式：直接回显
    this.buffer.addLine(`执行：${cmd}（Mock）`);

    this.inputCommand = '';
    this.updateOutput();
  }

  // 向上箭头 - 历史命令
  historyUp() {
    if (this.commandHistory.length === 0) return;
    if (this.historyIndex > 0) {
      this.historyIndex--;
      this.inputCommand = this.commandHistory[this.historyIndex];
    }
  }

  // 向下箭头 - 历史命令
  historyDown() {
    if (this.historyIndex < this.commandHistory.length - 1) {
      this.historyIndex++;
      this.inputCommand = this.commandHistory[this.historyIndex];
    } else {
      this.historyIndex = this.commandHistory.length;
      this.inputCommand = '';
    }
  }

  updateOutput() {
    this.outputText = this.buffer.getText();
  }

  clearTerminal() {
    this.buffer.clear();
    this.updateOutput();
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
          Text(`${this.server.username}@${this.server.host}`)
            .fontSize(12)
            .fontColor('#9ca3af')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 状态指示
        Row({ space: 6 }) {
          if (this.isConnected) {
            Circle().fill('#10b981').width(8).height(8)
          } else if (this.isConnecting) {
            Circle().fill('#f59e0b').width(8).height(8)
          } else {
            Circle().fill('#ef4444').width(8).height(8)
          }
          Text(this.statusText)
            .fontSize(12)
            .fontColor('#fff')
        }

        Button('断开')
          .backgroundColor('#dc2626')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ left: 10, right: 10 })
          .height(32)
          .onClick(() => this.disconnect())
      }
      .width('100%')
      .height(60)
      .backgroundColor('#111827')
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 终端显示区域
      Scroll() {
        Text(this.outputText)
          .fontSize(14)
          .fontFamily('monospace')
          .fontColor('#33ff33')
          .width('100%')
          .padding(12)
      }
      .layoutWeight(1)
      .backgroundColor('#0c0c0c')
      .scrollable(ScrollDirection.Vertical)
      .align(Alignment.TopStart)

      // 输入区域
      Row({ space: 8 }) {
        Text('$')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#33ff33')
        
        TextInput({ placeholder: '输入命令...', text: this.inputCommand })
          .height(44)
          .backgroundColor('#1a1a1a')
          .border({ width: 1, color: '#333', radius: 8 })
          .padding({ left: 10, right: 10 })
          .fontSize(14)
          .fontColor('#33ff33')
          .onChange((v) => this.inputCommand = v)
          .onSubmit(() => this.sendCommand())

        Button('发送')
          .backgroundColor('#10b981')
          .fontColor('#fff')
          .fontSize(14)
          .padding({ left: 16, right: 16 })
          .height(44)
          .enabled(this.isConnected)
          .onClick(() => this.sendCommand())
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#111827')

      // 快捷操作栏
      Row({ space: 8 }) {
        Button('清屏')
          .backgroundColor('#374151')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => this.clearTerminal())
        Button('重连')
          .backgroundColor('#374151')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => this.connect())
        Button('Ctrl+C')
          .backgroundColor('#374151')
          .fontColor('#fff')
          .fontSize(12)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => {
            this.inputCommand = '\x03';
            this.sendCommand();
          })
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#111827')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0c0c0c')
  }
}

