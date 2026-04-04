#!/usr/bin/env python3
"""
小红书预热脚本 — 模拟真人浏览行为，在发帖前执行。
使用 patchright（反检测 Playwright）控制浏览器。

用法：
  python3 warmup.py myaccount --sau-dir ~/Projects/social-auto-upload
  python3 warmup.py myaccount --sau-dir ~/Projects/social-auto-upload --headed
"""

import asyncio
import random
import sys
import json
from pathlib import Path

# 预热参数
BROWSE_COUNT_MIN = 3
BROWSE_COUNT_MAX = 5
SCROLL_PAUSE_MIN = 5
SCROLL_PAUSE_MAX = 15
LIKE_COUNT_MIN = 1
LIKE_COUNT_MAX = 2
NOTE_LOAD_WAIT = 3
POST_WARMUP_DELAY_MIN = 30
POST_WARMUP_DELAY_MAX = 90


async def warmup(account: str, sau_dir: Path, headed: bool = False):
    cookie_file = sau_dir / "cookies" / f"xiaohongshu_{account}.json"
    
    if not cookie_file.exists():
        print(f"❌ Cookie 文件不存在: {cookie_file}")
        print("   请先登录：sau xiaohongshu login --account <account>")
        return False

    cookies = json.loads(cookie_file.read_text())
    browse_count = random.randint(BROWSE_COUNT_MIN, BROWSE_COUNT_MAX)
    like_count = random.randint(LIKE_COUNT_MIN, LIKE_COUNT_MAX)
    
    print(f"🫀 预热开始：浏览 {browse_count} 篇笔记，点赞 {like_count} 篇")
    
    # 添加 sau 项目路径（用于 import patchright）
    sys.path.insert(0, str(sau_dir))
    from patchright.async_api import async_playwright
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(
            headless=not headed,
            args=["--disable-blink-features=AutomationControlled"]
        )
        context = await browser.new_context(
            viewport={"width": 390, "height": 844},  # iPhone 模拟
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        )
        
        # 注入 cookies
        for cookie in cookies:
            await context.add_cookies([cookie])
        
        page = await context.new_page()
        
        # 1. 打开小红书首页（探索页）
        print("📱 打开小红书探索页...")
        await page.goto("https://www.xiaohongshu.com/explore", wait_until="networkidle")
        await asyncio.sleep(random.uniform(2, 5))
        
        # 2. 随机浏览笔记
        liked = 0
        for i in range(browse_count):
            # 随机滚动
            scroll_y = random.randint(300, 800)
            await page.evaluate(f"window.scrollBy(0, {scroll_y})")
            await asyncio.sleep(random.uniform(1, 3))
            
            # 尝试点击一篇笔记
            note_links = await page.query_selector_all("a[href*='/explore/']")
            if note_links:
                link = random.choice(note_links[:5])
                href = await link.get_attribute("href")
                
                if href:
                    # 在新 tab 打开笔记
                    note_page = await context.new_page()
                    full_url = href if href.startswith("http") else f"https://www.xiaohongshu.com{href}"
                    
                    try:
                        await note_page.goto(full_url, wait_until="networkidle")
                        await asyncio.sleep(random.uniform(NOTE_LOAD_WAIT, NOTE_LOAD_WAIT + 3))
                        
                        # 随机滚动阅读
                        for _ in range(random.randint(2, 5)):
                            scroll = random.randint(100, 400)
                            await note_page.evaluate(f"window.scrollBy(0, {scroll})")
                            await asyncio.sleep(random.uniform(SCROLL_PAUSE_MIN, SCROLL_PAUSE_MAX))
                        
                        # 随机点赞
                        if liked < like_count and random.random() < 0.5:
                            like_btn = await note_page.query_selector(".like-wrapper, [class*='like']")
                            if like_btn:
                                await like_btn.click()
                                liked += 1
                                print(f"  ❤️ 点赞了第 {i+1} 篇笔记")
                                await asyncio.sleep(random.uniform(1, 3))
                        
                    except Exception as e:
                        print(f"  ⚠️ 笔记加载失败: {e}")
                    finally:
                        await note_page.close()
            
            print(f"  📖 已浏览 {i+1}/{browse_count} 篇")
        
        # 3. 回到首页再滚动几下
        await page.bring_to_front()
        for _ in range(random.randint(2, 4)):
            scroll = random.randint(200, 600)
            await page.evaluate(f"window.scrollBy(0, {scroll})")
            await asyncio.sleep(random.uniform(2, 5))
        
        await browser.close()
    
    # 4. 发帖前随机延迟
    delay = random.randint(POST_WARMUP_DELAY_MIN, POST_WARMUP_DELAY_MAX)
    print(f"⏳ 预热完成，等待 {delay} 秒后可以发帖...")
    await asyncio.sleep(delay)
    
    print("✅ 预热完成，可以安全发帖")
    return True


def main():
    if len(sys.argv) < 2:
        print("用法: python3 warmup.py <account> --sau-dir <path> [--headed]")
        sys.exit(1)

    import argparse
    parser = argparse.ArgumentParser(description="小红书预热脚本")
    parser.add_argument("account", help="小红书账号名")
    parser.add_argument("--sau-dir", required=True, help="social-auto-upload 项目路径")
    parser.add_argument("--headed", action="store_true", help="有头模式")
    args = parser.parse_args()

    sau_dir = Path(args.sau_dir).expanduser().resolve()
    asyncio.run(warmup(account=args.account, sau_dir=sau_dir, headed=args.headed))


if __name__ == "__main__":
    main()
