---
name: platform-bridge
description: "平台适配器（抖音/小红书/公众号/YouTube/B站）。统一下载接口，隐藏各平台差异。Use when: 下载视频, 抖音链接, 小红书笔记, youtube下载, bilibili下载, 平台下载, 视频提取, download douyin, download xiaohongshu."
requires:
  bins: ["python3", "yt-dlp"]
  modules: ["requests", "playwright"]
---

# Platform Bridge - 平台适配器

**Pattern: Tool Wrapper** (Google ADK) — 统一适配器层，包装多个外部平台 API 和下载工具，暴露一致接口。

## USE FOR

- "下载这个抖音视频" / "帮我存这个链接"
- "下载小红书笔记" / "把这个 B 站视频下载下来"
- "download this YouTube video"
- 用户粘贴任意平台视频 URL

## When to Use

Use when the user pastes a video/content link from Douyin, Xiaohongshu, YouTube, Bilibili, or WeChat (公众号), or says "下载", "帮我存", "download this", "extract metadata". Also triggered automatically by the content-inbox workflow.

**Don't use when:** The user wants to stream (not download) or is asking about platform APIs unrelated to download/extraction.

## Prerequisites

- Python 3.8+
- `pip install requests playwright`
- `pip install yt-dlp`
- TikHub API token（抖音/小红书优先方案）：配置在 `~/.openclaw/config.json`

## Quick Start

```python
# 调用统一下载接口
from platform_bridge import download

result = download("https://v.douyin.com/xxx", {"quality": "highest"})
print(result["video_path"])   # /tmp/video.mp4
print(result["platform"])     # "douyin"
print(result["method"])       # "tikhub"
```

```bash
# CLI 方式（如果 scripts/ 有 download.py）
python ~/.openclaw/skills/platform-bridge/scripts/download.py "https://v.douyin.com/xxx"
```

## 核心职责

1. **统一接口**：为 content-inbox 提供统一的下载 API
2. **平台适配**：隐藏各平台的下载差异
3. **多种方式**：TikHub API、Playwright、yt-dlp
4. **自动选择**：根据平台和配置选择最佳下载方式
5. **错误处理**：失败自动切换备用方案

## 支持的平台

| 平台 | 优先方式 | 备用方式 | API 成本 |
|------|---------|---------|---------|
| **抖音** | TikHub API | Playwright | $0.001/次 |
| **小红书** | TikHub API | Playwright | $0.001/次 |
| **公众号** | Playwright | - | 免费 |
| **YouTube** | yt-dlp | - | 免费 |
| **B站** | yt-dlp | - | 免费 |

## 统一接口

### download(url, options)

```python
def download(url: str, options: dict) -> DownloadResult:
    """
    统一下载接口
    
    Args:
        url: 视频链接
        options: {
            "quality": "highest" | "medium" | "low",
            "metadata": True | False,
            "output_dir": "path/to/output"
        }
    
    Returns:
        DownloadResult {
            "video_path": "path/to/video.mp4",
            "metadata": {
                "title": "xxx",
                "author": "xxx",
                "likes": 123,
                "publish_time": "2026-03-12"
            },
            "platform": "douyin",
            "method": "tikhub"
        }
    """
```

## 适配器实现

### DouyinAdapter（抖音）

```python
class DouyinAdapter:
    def download(self, url: str, options: dict):
        # 方法 1：TikHub API（优先）
        try:
            return self._download_via_tikhub(url, options)
        except Exception as e:
            log(f"TikHub 失败: {e}")
        
        # 方法 2：Playwright（备用）
        try:
            return self._download_via_playwright(url, options)
        except Exception as e:
            log(f"Playwright 失败: {e}")
            raise DownloadError("所有下载方式失败")
    
    def _download_via_tikhub(self, url: str, options: dict):
        # 调用 TikHub API
        # 配置：~/.openclaw/config.json
        # {"tikhub_api_token": "xxx"}
        
        modal_id = self._extract_modal_id(url)
        api_url = f"https://api.tikhub.io/api/v1/douyin/web/fetch_one_video?aweme_id={modal_id}"
        
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(api_url, headers=headers)
        
        # 提取视频 URL
        video_url = response.json()["data"]["aweme_detail"]["video"]["bit_rate"][0]["play_addr"]["url_list"][0]
        
        # 下载视频
        return self._download_video(video_url, options)
```

### XiaohongshuAdapter（小红书）

```python
class XiaohongshuAdapter:
    def download(self, url: str, options: dict):
        # TikHub API（优先）
        # Playwright（备用）
        pass
```

### WechatAdapter（公众号）

```python
class WechatAdapter:
    def download(self, url: str, options: dict):
        # 公众号文章通常没有视频
        # 主要提取文字和图片
        pass
```

### YouTubeAdapter（YouTube）

```python
class YouTubeAdapter:
    def download(self, url: str, options: dict):
        # yt-dlp（唯一方式）
        cmd = f'yt-dlp -f "best[ext=mp4]" -o "{output_path}" "{url}"'
        subprocess.run(cmd, shell=True)
        return DownloadResult(...)
```

### BilibiliAdapter（B站）

```python
class BilibiliAdapter:
    def download(self, url: str, options: dict):
        # yt-dlp（唯一方式）
        pass
```

## 平台检测

```python
def detect_platform(url: str) -> str:
    if "douyin.com" in url or "v.douyin.com" in url:
        return "douyin"
    elif "xiaohongshu.com" in url:
        return "xiaohongshu"
    elif "mp.weixin.qq.com" in url:
        return "wechat"
    elif "youtube.com" in url or "youtu.be" in url:
        return "youtube"
    elif "bilibili.com" in url or "b23.tv" in url:
        return "bilibili"
    else:
        raise UnknownPlatformError(f"Unknown platform: {url}")
```

## TikHub API 集成

### 配置

```json
// ~/.openclaw/config.json
{
  "tikhub_api_token": "jLdHX+g6gHKlpmWwTYnK2zjhCCK1cbR9skfco07adcCQhFi+ByzbVjmxKw=="
}
```

### API 端点

```
抖音视频：/api/v1/douyin/web/fetch_one_video
小红书笔记：/api/v1/xiaohongshu/app/v2/fetch_one_note
```

### 错误处理

```python
if response.status_code == 400:
    # Cookie 过期或反爬拦截
    log("TikHub API 返回 400，可能需要更新 Cookie")
    raise TikHubError("Cookie expired")

if response.status_code == 401:
    # Token 无效
    raise TikHubError("Invalid token")

if response.json().get("code") != 200:
    # 其他错误
    raise TikHubError(response.json().get("message"))
```

## Playwright 备用方案

### 适用场景

- TikHub API 失败
- 平台不支持 TikHub
- 需要登录才能访问的内容

### 实现

```python
async def _download_via_playwright(self, url: str, options: dict):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        # 监听视频请求
        video_urls = []
        page.on("response", lambda response: 
            video_urls.append(response.url) 
            if "video" in response.url and ".mp4" in response.url
            else None
        )
        
        # 打开页面
        await page.goto(url)
        await page.wait_for_timeout(5000)
        
        # 下载视频
        if video_urls:
            return self._download_video(video_urls[0], options)
        else:
            raise DownloadError("No video URL found")
```

## 元数据提取

### 抖音

```json
{
  "title": "水果=果糖？，十恶不赦？千万别吃？",
  "author": "陈石（营养，挨揍，撸铁）",
  "likes": 12345,
  "comments": 678,
  "shares": 90,
  "publish_time": "2026-03-12",
  "duration": 768,
  "description": "2026年了，怎么还有人不敢吃水果..."
}
```

### 小红书

```json
{
  "title": "xxx",
  "author": "xxx",
  "likes": xxx,
  "collects": xxx,
  "comments": xxx,
  "publish_time": "2026-03-12"
}
```

## 成本控制

### TikHub API

```
基础价格：$0.001/次
阶梯折扣：
  - 0-1000 次/天：$0.001/次
  - 1000-5000 次/天：$0.0009/次
  - 5000+ 次/天：更低
```

### 免费方案

```
Playwright（本地）：免费
yt-dlp（本地）：免费
```

## 错误类型

### DownloadError

```python
class DownloadError(Exception):
    """所有下载方式失败"""
    pass
```

### TikHubError

```python
class TikHubError(Exception):
    """TikHub API 错误"""
    pass
```

### UnknownPlatformError

```python
class UnknownPlatformError(Exception):
    """未知平台"""
    pass
```

## 统计

| 命令 | 动作 |
|------|------|
| "平台统计" | 显示各平台的下载数、成功率 |
| "TikHub 配额" | 显示 TikHub API 使用情况 |

## 配置

### 全局配置（~/.openclaw/config.json）

```json
{
  "tikhub_api_token": "xxx",
  "download": {
    "default_quality": "highest",
    "timeout": 300,
    "retry_count": 3,
    "prefer_method": "tikhub"
  }
}
```

## 适配器位置

- `adapters/douyin.py`：抖音适配器
- `adapters/xiaohongshu.py`：小红书适配器
- `adapters/wechat.py`：公众号适配器
- `adapters/youtube.py`：YouTube 适配器
- `adapters/bilibili.py`：B站适配器

## Examples

### Example 1: Download a Douyin video

**User says:** "帮我下载这个抖音视频 https://v.douyin.com/abc123"

**Steps:**
1. Detect platform → `douyin`
2. Try TikHub API first
3. Download video to `/tmp/video.mp4`

**Output:**
```json
{
  "video_path": "/tmp/douyin_abc123.mp4",
  "platform": "douyin",
  "method": "tikhub",
  "metadata": {"title": "示例视频", "author": "xxx", "likes": 12345}
}
```

**Reply:** "已下载 ✅ 保存至 `/tmp/douyin_abc123.mp4`"

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `TikHubError: Cookie expired` | TikHub API 返回 400，Cookie 失效 | 更新 `~/.openclaw/config.json` 中的 `tikhub_api_token` |
| `TikHubError: Invalid token` | Token 无效或过期 | 重新获取 TikHub API token 并写入配置 |
| `UnknownPlatformError` | 链接不匹配已知平台 | 检查 URL 格式；手动指定平台 |
| `DownloadError: No video URL found` | Playwright 未能捕获视频请求 | 增加 `wait_ms`；检查页面是否需要登录 |
| `DownloadError: All methods failed` | TikHub + Playwright 均失败 | 检查网络；核实链接有效性；查看日志 |
| `FileNotFoundError` on output | 输出目录不存在 | 创建目标目录或使用 `/tmp/` |

## 安全边界

- ✅ 只下载用户主动提供的链接
- ✅ 不存储用户隐私数据
- ✅ API Token 加密存储
- ✅ 失败不重试超过 3 次
