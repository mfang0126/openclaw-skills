#!/usr/bin/env python3
"""
小红书安全发帖包装脚本 — 在 sau 外面套一层人类节奏的延迟。
模拟真人操作：打开浏览器 → 停留 → 填内容 → 提交 → 再停留 → 关闭。

用法：
  python3 publish.py --account myaccount --sau-dir ~/Projects/social-auto-upload \
    --type note --title "标题" --note "正文" --tags "tag1,tag2" --images img1.png img2.png
  python3 publish.py --account myaccount --sau-dir ~/Projects/social-auto-upload \
    --type video --title "标题" --desc "简介" --tags "tag1,tag2" --file video.mp4
"""

import subprocess
import random
import sys
import time
import argparse
from pathlib import Path


def human_delay(label: str, min_s: int, max_s: int):
    """随机延迟，打印进度"""
    delay = random.randint(min_s, max_s)
    print(f"⏳ {label}（等待 {delay} 秒）...")
    time.sleep(delay)
    print(f"✅ {label}完成")
    return delay


def run_sau(sau_dir: Path, venv_activate: str, args: list, label: str):
    """执行 sau 命令"""
    cmd = f"cd {sau_dir} && {venv_activate} && sau xiaohongshu {' '.join(args)}"
    print(f"🚀 {label}...")
    result = subprocess.run(cmd, shell=True, capture_output=False, text=True)
    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser(description="小红书安全发帖")
    # 账号和路径参数
    parser.add_argument("--account", required=True, help="小红书账号名（对应 cookie 文件名）")
    parser.add_argument("--sau-dir", required=True, help="social-auto-upload 项目路径")
    # 发帖内容参数
    parser.add_argument("--type", choices=["note", "video"], required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--note", default=None, help="图文正文")
    parser.add_argument("--desc", default=None, help="视频简介")
    parser.add_argument("--tags", default=None, help="标签，逗号分隔")
    parser.add_argument("--images", nargs="+", default=None, help="图片路径")
    parser.add_argument("--file", default=None, help="视频文件路径")
    parser.add_argument("--schedule", default=None, help="定时发布 YYYY-MM-DD HH:MM")
    # 行为控制参数
    parser.add_argument("--skip-warmup", action="store_true", help="跳过预热")
    parser.add_argument("--headed", action="store_true", help="有头模式")
    args = parser.parse_args()

    sau_dir = Path(args.sau_dir).expanduser().resolve()
    venv_activate = f"source {sau_dir / '.venv' / 'bin' / 'activate'}"

    total_start = time.time()

    print("=" * 50)
    print("📕 小红书安全发帖流程启动")
    print(f"   账号: {args.account}")
    print(f"   sau 路径: {sau_dir}")
    print("=" * 50)

    # Phase 1: 预热（浏览 + 互动）
    if not args.skip_warmup:
        print("\n📡 Phase 1: 真人预热")
        print("-" * 30)
        warmup_script = Path(__file__).parent / "warmup.py"
        if warmup_script.exists():
            result = subprocess.run(
                ["python3", str(warmup_script), args.account, "--sau-dir", str(sau_dir), "--headless"],
                capture_output=False, text=True
            )
            if result.returncode != 0:
                print("⚠️ 预热失败，继续发帖（风险略高）")
        else:
            print("⚠️ 预热脚本不存在，跳过")

    # Phase 2: 发帖前延迟（模拟"打开App → 想了想 → 决定发"）
    print("\n📝 Phase 2: 准备发帖")
    print("-" * 30)
    human_delay("模拟打开App浏览推荐页", 15, 30)
    human_delay("犹豫了一下要不要发", 5, 15)

    # Phase 3: 执行发帖
    print("\n📤 Phase 3: 执行发布")
    print("-" * 30)

    sau_args = []
    if args.type == "note":
        sau_args = ["upload-note", "--account", args.account, "--title", args.title]
        if args.note:
            sau_args += ["--note", args.note]
        if args.images:
            sau_args += ["--images", *args.images]
        if args.tags:
            sau_args += ["--tags", args.tags]
        if args.schedule:
            sau_args += ["--schedule", args.schedule]
    else:
        sau_args = ["upload-video", "--account", args.account, "--title", args.title]
        if args.desc:
            sau_args += ["--desc", args.desc]
        if args.file:
            sau_args += ["--file", args.file]
        if args.tags:
            sau_args += ["--tags", args.tags]
        if args.schedule:
            sau_args += ["--schedule", args.schedule]

    if args.headed:
        sau_args.append("--headed")
    else:
        sau_args.append("--headless")

    success = run_sau(sau_dir, venv_activate, sau_args, "发布笔记/视频")

    if not success:
        print("❌ 发布失败")
        sys.exit(1)

    # Phase 4: 发帖后停留（模拟"看了看有没有发出去 → 退出"）
    print("\n👀 Phase 4: 发帖后行为")
    print("-" * 30)
    human_delay("看了看笔记是否发布成功", 10, 25)
    human_delay("顺手刷了刷推荐页", 15, 40)

    total_time = int(time.time() - total_start)
    print(f"\n{'=' * 50}")
    print(f"✅ 全部完成，总耗时 {total_time} 秒（{total_time // 60}分{total_time % 60}秒）")
    print(f"{'=' * 50}")


if __name__ == "__main__":
    main()
// test
