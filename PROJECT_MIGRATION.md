# HarmonySSH2 项目迁移说明

## 项目背景

此项目是基于 DevEco Studio 创建的鸿蒙标准项目模板，已将修复后的 HarmonySSH 代码迁移至此。

## 迁移内容

### 1. 文件结构迁移
- ✅ `pages/` - 所有页面文件 (Login, Home, ServerForm, Terminal, Sftp, Settings)
- ✅ `services/ApiService.ts` - API 服务层
- ✅ `utils/CommonUtils.ts` - 工具函数

### 2. 配置更新
- ✅ `module.json5` - 添加网络权限和页面路由
- ✅ `main_pages.json` - 注册所有页面
- ✅ `oh-package.json5` - 添加网络相关依赖
- ✅ `EntryAbility.ets` - 修改默认启动页面为 Login

### 3. 权限配置
添加了必要的网络权限：
- `ohos.permission.INTERNET` - 网络访问权限
- `ohos.permission.GET_NETWORK_INFO` - 网络信息获取权限

### 4. 依赖添加
- `@kit.NetworkKit` - 网络工具包
- `@ohos.net.http` - HTTP 客户端

## API 修复内容（已包含）

### 修复的问题
1. **参数名称错误**: `server` → `serverId`
2. **WebSocket 格式**: 添加 `type: 'data'` 字段
3. **类型定义不匹配**: 更新 SftpFile 接口
4. **SFTP 操作参数**: 修复删除和重命名操作

### 测试验证
- ✅ 登录 API: `admin/admin123`
- ✅ 服务器列表: 正常返回
- ✅ SFTP 列表: 正常工作
- ✅ WebSocket: 参数格式正确

## 项目结构

```
HarmonySSH2/
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/EntryAbility.ets
│       │   ├── pages/           # 所有页面文件
│       │   ├── services/ApiService.ts
│       │   └── utils/CommonUtils.ts
│       ├── module.json5         # 模块配置（已更新）
│       └── resources/
│           └── base/profile/main_pages.json  # 页面路由（已更新）
├── oh-package.json5            # 依赖配置（已更新）
└── hvigorfile.ts               # 构建配置
```

## 开发说明

1. **启动应用**: 默认打开 Login 页面
2. **API 配置**: 在 `ApiService.ts` 中修改 `BASE_URL`
3. **权限管理**: 网络权限已配置，无需额外请求
4. **构建工具**: 使用 DevEco Studio 或 hvigor 构建

## 注意事项

- 项目使用鸿蒙标准项目结构，与 DevEco Studio 完全兼容
- 所有 API 调用错误已修复，可直接使用
- 网络权限已配置，无需运行时请求
- 页面路由已正确注册

---

**迁移时间**: 2026-03-19
**迁移者**: 大龙虾 🦞