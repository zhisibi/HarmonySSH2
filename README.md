# HarmonySSH - 鸿蒙 SSH 客户端

基于 ArkTS + ArkUI 开发的原生鸿蒙 SSH 客户端，支持对接 WebSSH 后端服务。

## 🚀 功能特性

- 🔐 **安全登录** - 支持自定义后端地址和账号密码登录
- 🖥️ **服务器管理** - 添加、编辑、删除 SSH 服务器配置
- 💻 **SSH 终端** - WebSocket 实时命令行交互
- 📁 **SFTP 文件管理** - 浏览、上传、下载、删除文件
- ⚙️ **设置中心** - 修改密码、数据备份/恢复

## 📋 系统要求

- HarmonyOS NEXT API 12+
- DevEco Studio 4.0+
- 支持的网络权限

## 🔧 安装配置

### 1. 克隆项目
```bash
git clone https://github.com/zhisibi/HarmonySSH2.git
```

### 2. 配置后端地址
在登录页面输入您的 WebSSH 后端服务地址：
- 默认地址: `http://192.168.100.20:3000`
- 支持自定义 HTTP/HTTPS 地址
- 支持动态修改，无需重新编译

### 3. 登录凭据
- 用户名: `admin`
- 密码: `admin123`

## 🛠️ 开发说明

### 项目结构
```
HarmonySSH2/
├── entry/src/main/ets/
│   ├── pages/           # 页面组件
│   │   ├── Login.ets    # 登录页（含后端地址配置）
│   │   ├── Home.ets     # 控制面板
│   │   ├── Terminal.ets # SSH终端
│   │   └── Sftp.ets     # 文件管理
│   ├── services/        # 服务层
│   │   └── ApiService.ts # API接口封装
│   └── utils/           # 工具函数
├── resources/           # 资源文件
└── module.json5         # 模块配置
```

### API 配置
编辑 `src/main/ets/services/ApiService.ts`:
```typescript
// 后端地址将在登录时由用户输入
const BASE_URL = userInputBaseUrl;  // 动态设置
const WS_URL = userInputBaseUrl.replace('http', 'ws');
```

## 🌐 WebSSH 后端要求

后端需要实现以下 API 接口：

### 认证接口
- `POST /api/login` - 用户登录
- `POST /api/logout` - 用户登出

### 服务器管理  
- `GET /api/servers` - 获取服务器列表
- `POST /api/servers` - 添加服务器
- `PUT /api/servers/:id` - 编辑服务器
- `DELETE /api/servers/:id` - 删除服务器

### SSH 终端
- WebSocket `ws://host/ws/ssh` - 实时命令行交互

### SFTP 文件操作
- `GET /api/sftp/list` - 列出目录
- `POST /api/sftp/upload` - 上传文件
- `GET /api/sftp/download` - 下载文件
- `POST /api/sftp/mkdir` - 创建目录

## 📱 页面预览

### 登录页面
- 后端地址输入框
- 用户名/密码输入框  
- 登录按钮
- 错误提示显示

### 控制面板
- 服务器卡片列表
- 快捷操作按钮（SSH、SFTP、编辑、删除）
- 添加服务器浮动按钮

### SSH 终端
- 实时命令输入输出
- 终端样式优化
- 连接状态指示

### SFTP 文件浏览器
- 文件目录树浏览
- 文件操作菜单
- 上传下载进度

## 🔒 安全特性

- 密码加密存储
- Token 认证机制
- 网络通信加密
- 会话超时管理

## 🐛 问题反馈

如遇问题请提交 Issue 或联系开发团队。

## 📄 开源协议

MIT License

---

**开发团队**: 大龙虾 🦞  
**更新日期**: 2026-03-19