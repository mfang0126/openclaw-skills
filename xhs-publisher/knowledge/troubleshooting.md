# 故障排查

## 找不到 `sau` 命令

可以尝试以下方式：

```powershell
.\.venv\Scripts\Activate.ps1
sau xiaohongshu --help
```

```powershell
.\.venv\Scripts\sau.exe xiaohongshu --help
```

```bash
uv run sau xiaohongshu --help
```

如果当前环境还没有安装项目：

```bash
uv pip install -e .
```

## cookie 无效或已过期

先检查 cookie 状态：

```bash
sau xiaohongshu check --account <account>
```

如果无效，就重新登录：

```bash
sau xiaohongshu login --account <account>
```

## 无头登录二维码处理

如果用户无法使用终端二维码输出：

- 查找 CLI 打印出来的临时二维码图片
- agent 不要只把图片路径回给用户
- agent 应优先直接把本地二维码图片展示/发送给用户扫码

如果终端二维码显示不正常，优先使用保存下来的图片路径，而不是反复尝试随机的终端设置。

## 上传参数缺失

### 视频上传

最少需要：

- `--account`
- `--file`
- `--title`

### 图文上传

最少需要：

- `--account`
- `--images`
- `--title`

`--note` 当前是可选图文正文。

## 定时发布

时间格式使用：

```text
YYYY-MM-DD HH:MM
```

如果不需要定时发布，去掉 `--schedule` 即可改为立即发布。

## publish.py 执行失败

- 检查脚本路径：从 config.json 读取 sauDir，确认脚本在 skill 根目录的 scripts/ 下
- publish.py 需要两个必需参数：`--account` 和 `--sau-dir`
- publish.py 需要在 sau 虚拟环境下运行（脚本内部会自动 source activate）
- 如果脚本超时无响应（正常耗时 3-6 分钟），超过 10 分钟可视为卡死，Ctrl+C 中断后检查浏览器进程

## state.json 异常

- **文件不存在**：首次使用前在 skill 根目录创建：`echo '{"posts":[]}' > state.json`
- **JSON 格式错误**：手动修复或删除重建（会丢失历史记录）
- **日期筛选异常**：state.json 中的 `date` 格式必须是 `YYYY-MM-DD`，检查是否有格式不一致的记录
