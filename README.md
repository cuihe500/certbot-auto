# Certbot 自动化安装与证书申请脚本

这是一个用于自动化安装 Certbot 并申请 SSL 证书的 Shell 脚本。脚本支持通过 Cloudflare DNS 验证方式申请通配符证书。

## 功能特点

- 自动安装 Certbot 及其依赖
- 支持 Cloudflare DNS 验证
- 自动配置证书自动续期
- 支持申请通配符证书
- 支持多域名证书申请

## 系统要求

- Debian/Ubuntu 系统
- Root 权限
- Python 3
- 已配置的 Cloudflare 域名

## 使用前准备

1. 确保您的域名已经添加到 Cloudflare
2. 在 Cloudflare 面板中创建 API Token
   - 进入 Cloudflare 控制面板
   - 导航到 `My Profile > API Tokens`
   - 创建一个新的 Token，确保具有 `Zone:DNS:Edit` 权限

## 安装和使用

### 1. 下载并配置

下载脚本并添加执行权限：
```bash
wget https://raw.githubusercontent.com/cuihe500/certbot-auto/refs/heads/main/certbot-auto.sh
chmod +x certbot-auto.sh
```

### 2. 运行脚本

基本用法：
```bash
./certbot-auto.sh [选项]
```

### 3. 可用选项

- `install`：安装 Certbot 及其依赖
- `cert`：申请证书
- `auto`：自动安装 Certbot 并申请证书
- `help`：显示帮助信息

### 4. 使用示例

安装 Certbot 及其依赖：
```bash
./certbot-auto.sh install
```

申请证书：
```bash
./certbot-auto.sh cert
```

一键完成所有操作：
```bash
./certbot-auto.sh auto
```

## 证书说明

### 证书位置
证书文件将保存在：`/etc/letsencrypt/live/你的域名/`

### 证书文件
- `fullchain.pem`：完整的证书链
- `privkey.pem`：私钥
- `cert.pem`：域名证书
- `chain.pem`：中间证书

### 自动续期
脚本会自动配置证书续期任务，每天凌晨和中午会检查证书是否需要续期。

## 安全说明

- Cloudflare API Token 将被安全存储在 `/root/.secrets/certbot/cloudflare.ini`
- 凭证文件权限设置为 600，确保只有 root 用户可以访问
- 建议定期更换 API Token

## 故障排除

### 权限错误
- 确保使用 root 用户运行脚本
- 检查 Cloudflare API Token 权限

### 证书申请失败
- 确认域名已正确添加到 Cloudflare
- 检查 API Token 是否有效
- 查看 Certbot 日志获取详细错误信息

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个脚本。

## 许可证

MIT License
