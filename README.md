# HarmonySSH - 鸿蒙 SSH 客户端

基于 ArkTS + ArkUI 开发的原生鸿蒙 SSH 客户端，支持 WebSSH 后端管理。

## ✨ 功能特性

- 🔐 **安全登录** - 支持后端地址配置和账号登录
- 🖥️ **服务器管理** - 添加、编辑、删除 SSH 服务器
- 💻 **SSH 终端** - WebSocket 实时交互，支持命令执行
- 📁 **SFTP 文件管理** - 浏览、上传、下载文件
- ⚙️ **设置管理** - 修改密码、数据备份/恢复

## 🚀 快速开始

### 1. 配置后端地址

在登录页面输入您的 WebSSH 后端地址：
- 默认地址：`http://192.168.100.20:3000`
- 支持 HTTP 和 HTTPS
- 支持自定义端口

### 2. 登录账号
- 用户名：`admin`
- 密码：`admin123`

### 3. 开始使用
- 查看服务器列表
- 连接 SSH 终端
- 管理文件系统

## 📦 项目结构

```
HarmonySSH2/
├── entry/src/main/ets/
│   ├── pages/           # 页面组件
│   │   ├── Login.ets    # 登录页面
│   │   ├── Home.ets     # 主页/服务器列表
│   │   ├── ServerForm.ets # 服务器表单
│   │   ├── Terminal.ets # SSH 终端
│   │   ├── Sftp.ets     # SFTP 文件管理
│   │   └── Settings.ets # 设置页面
│   ├── services/        # 服务层
│   │   └── ApiService.ts # API 服务
│   ├── utils/           # 工具函数
│   └── entryability/    # 应用入口
├── module.json5         # 模块配置
└── oh-package.json5     # 依赖配置
```

## 🔧 开发配置

### 后端地址配置

在 `ApiService.ts` 中修改默认后端地址：

```typescript
const BASE_URL = 'http://your-server:3000';
const WS_URL = 'ws://your-server:3000';
```

### 权限配置

应用需要以下权限：
- `ohos.permission.INTERNET` - 网络访问
- `ohos.permission.GET_NETWORK_INFO` - 网络信息

### 依赖项

- `@kit.NetworkKit` - 网络工具包
- `@ohos.net.http` - HTTP 客户端

## 🌐 API 接口

### 认证接口
- `POST /api/login` - 用户登录
- `POST /api/logout` - 用户登出

### 服务器管理
- `GET /api/servers` - 获取服务器列表
- `POST /api/servers` - 添加服务器
- `PUT /api/servers/:id` - 编辑服务器
- `DELETE /api/servers/:id` - 删除服务器

### SFTP 文件操作
- `GET /api/sftp/list` - 列出目录
- `POST /api/sftp/upload` - 上传文件
- `GET /api/sftp/download` - 下载文件

### WebSocket SSH
- `ws://host/ws/ssh` - SSH 终端连接

## 🛠️ 构建运行

### 使用 DevEco Studio
1. 导入项目
2. 配置签名证书
3. 运行到设备/模拟器

### 命令行构建
```bash
# 安装依赖
npm install

# 构建项目
hvigor build
```

## 📝 使用说明

1. **首次使用**：在登录页面输入后端服务器地址
2. **登录账号**：使用管理员账号登录
3. **添加服务器**：在主页点击"添加服务器"
4. **连接终端**：点击服务器卡片的"SSH"按钮
5. **文件管理**：点击"SFTP"按钮浏览文件

## 🐛 故障排除

### 常见问题
1. **连接失败**：检查后端地址是否正确
2. **登录失败**：确认用户名密码正确
3. **网络错误**：检查网络权限配置

### 获取帮助
- 查看 [BUG_FIXES.md](./BUG_FIXES.md) 了解已知问题修复
- 查看 [PROJECT_MIGRATION.md](./PROJECT_MIGRATION.md) 了解项目迁移详情

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**开发团队**：大龙虾 🦞  
**最后更新**：2026-03-19