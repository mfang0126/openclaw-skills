# 运行环境要求

## 安装 sau CLI

sau（social-auto-upload）需要从源码安装：

```bash
cd ~/Projects/social-auto-upload
uv pip install -e .
```

## 安装浏览器驱动

sau 使用 patchright 作为浏览器驱动，需要安装 Chromium：

```bash
patchright install chromium
```

## 虚拟环境激活

### Bash / Zsh

```bash
source ~/Projects/social-auto-upload/.venv/bin/activate
```

### PowerShell (Windows)

```powershell
.\.venv\Scripts\Activate.ps1
```

### uv run（推荐，无需手动激活）

```bash
uv run sau xiaohongshu --help
```

## 验证安装

```bash
source ~/Projects/social-auto-upload/.venv/bin/activate && sau xiaohongshu --help
```

如果能看到帮助信息，说明安装成功。

## Headless vs Headed 模式

- **Headless**（默认）：浏览器在后台运行，不显示窗口。适合服务器/CI 环境。
- **Headed**：浏览器有可见窗口。适合本地调试、需要扫码登录的场景。

使用方式：
- sau 命令：添加 `--headed` 或 `--headless` 参数
- publish.py：同上，通过 `--headed` 或 `--headless` 参数控制
