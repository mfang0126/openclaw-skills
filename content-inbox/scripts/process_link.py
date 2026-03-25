#!/usr/bin/env python3
"""
内容链接处理主流程
"""

import sys
import os
import re
from pathlib import Path

# 添加脚本目录到路径
sys.path.insert(0, os.path.dirname(__file__))

from config_manager import ConfigManager
from preference_learner import PreferenceLearner


class ContentInboxProcessor:
    """内容链接处理器"""
    
    def __init__(self, workspace_dir: str = None, home_dir: str = None):
        self.workspace_dir = workspace_dir or os.path.expanduser("~/.openclaw/workspace")
        self.home_dir = home_dir or os.path.expanduser("~")
        
        # 初始化配置管理器
        self.config = ConfigManager(
            workspace_dir=self.workspace_dir,
            home_dir=self.home_dir
        )
        
        # 初始化学习器
        data_dir = os.path.join(self.workspace_dir, "skills/content-inbox/data")
        os.makedirs(data_dir, exist_ok=True)
        
        self.learner = PreferenceLearner(
            corrections_file=os.path.join(data_dir, "corrections.json"),
            memory_file=os.path.join(self.home_dir, ".openclaw/memory.md")
        )
    
    def detect_platform(self, message: str) -> str:
        """
        检测链接平台
        
        Args:
            message: 用户消息
        
        Returns:
            "douyin" | "xiaohongshu" | "wechat" | None
        """
        if any(x in message for x in ["v.douyin.com", "douyin.com"]):
            return "douyin"
        elif "xiaohongshu.com" in message:
            return "xiaohongshu"
        elif "mp.weixin.qq.com" in message:
            return "wechat"
        return None
    
    def extract_url(self, message: str, platform: str) -> str:
        """
        提取 URL
        
        Args:
            message: 用户消息
            platform: 平台
        
        Returns:
            URL 或 None
        """
        if platform == "douyin":
            # 匹配抖音短链接（支持下划线）
            match = re.search(r'(https?://v\.douyin\.com/[A-Za-z0-9_]+/?)', message)
            if match:
                return match.group(1)
            
            # 匹配抖音长链接
            match = re.search(r'(https?://www\.douyin\.com/video/\d+)', message)
            if match:
                return match.group(1)
        
        elif platform == "xiaohongshu":
            match = re.search(r'(https?://www\.xiaohongshu\.com/[^\s]+)', message)
            if match:
                return match.group(1)
        
        elif platform == "wechat":
            match = re.search(r'(https?://mp\.weixin\.qq\.com/[^\s]+)', message)
            if match:
                return match.group(1)
        
        return None
    
    def get_default_action(self, platform: str) -> str:
        """
        获取默认动作
        
        Args:
            platform: 平台
        
        Returns:
            "ask" | "A" | "B" | "C" | "D"
        """
        key = f"{platform}_default_action"
        return self.config.get(key, "ask")
    
    def process_link(self, message: str, user_choice: str = None):
        """
        处理链接（兼容旧版）
        """
        result = self.process_link_v2(message, user_choice)
        
        # 如果需要询问用户，返回 ask
        if result.get("action") == "ask":
            return {
                "action": "ask",
                "platform": result.get("platform"),
                "url": result.get("url"),
                "message": result.get("message")
            }
        
        return result
    
    def record_user_choice(self, platform: str, choice: str):
        """
        记录用户选择（用于学习）
        
        Args:
            platform: 平台
            choice: 用户选择（A/B/C/D）
        """
        key = f"{platform}_default_action"
        result = self.learner.record_correction(
            key=key,
            value=choice,
            context=f"{platform}视频处理"
        )
        
        return result
    
    def process_link_v2(self, message: str, user_choice: str = None):
        """
        处理链接的主流程（v2）
        
        Args:
            message: 用户消息
            user_choice: 用户选择（A/B/C/D），None 表示询问
        
        Returns:
            {
                "action": "download" | "ask" | "spawn_subagent",
                "platform": str,
                "url": str,
                "message": str,  # 给用户的回复
                "task": str,     # SubAgent 任务（如果需要）
                "learning": dict # 学习结果（如果需要）
            }
        """
        # 1. 检测平台
        platform = self.detect_platform(message)
        if not platform:
            return {
                "action": "error",
                "message": "未识别的链接平台"
            }
        
        # 2. 提取 URL
        url = self.extract_url(message, platform)
        if not url:
            return {
                "action": "error",
                "message": f"未找到{platform}链接"
            }
        
        # 3. 检查默认动作
        if not user_choice:
            default_action = self.get_default_action(platform)
            if default_action != "ask":
                user_choice = default_action
        
        # 4. 如果还是没有选择，询问用户
        if not user_choice:
            return {
                "action": "ask",
                "platform": platform,
                "url": url,
                "message": """✅ 已识别链接

要怎么处理？
A. 仅下载
B. 转写文字（~5 分钟）
C. 完整分析（转写+验证+素材化，~20 分钟）
D. 生成博客草稿（~30 分钟）

快捷方式："转写"/"深度分析"/"写博客"
"""
            }
        
        # 5. 记录用户选择（学习）
        learning_result = self.record_user_choice(platform, user_choice)
        
        # 6. 执行用户选择
        if user_choice == "A":
            # 仅下载，派 SubAgent
            return {
                "action": "spawn_subagent",
                "platform": platform,
                "url": url,
                "choice": user_choice,
                "task": f"用 {platform}-downloader 下载：{url}",
                "message": "✅ 开始下载...",
                "learning": learning_result
            }
        
        elif user_choice == "B":
            # 转写
            return {
                "action": "spawn_subagent",
                "platform": platform,
                "url": url,
                "choice": user_choice,
                "task": f"下载并转写：{url}",
                "message": "✅ 开始转写... 预计 5 分钟，完成后通知你",
                "learning": learning_result
            }
        
        elif user_choice == "C":
            # 完整分析
            return {
                "action": "spawn_subagent",
                "platform": platform,
                "url": url,
                "choice": user_choice,
                "task": f"下载并完整分析：{url}",
                "message": "✅ 开始完整分析... 预计 20 分钟",
                "learning": learning_result
            }
        
        elif user_choice == "D":
            # 博客草稿
            return {
                "action": "spawn_subagent",
                "platform": platform,
                "url": url,
                "choice": user_choice,
                "task": f"下载并生成博客草稿：{url}",
                "message": "✅ 开始生成博客草稿... 预计 30 分钟",
                "learning": learning_result
            }
        
        else:
            return {
                "action": "error",
                "message": f"未知选择：{user_choice}"
            }


def main():
    """测试主流程"""
    processor = ContentInboxProcessor()
    
    # 测试 1：抖音链接
    print("=== 测试 1：抖音链接 ===")
    result = processor.process_link("https://v.douyin.com/test123/")
    print(result)
    
    # 测试 2：带用户选择
    print("\n=== 测试 2：带用户选择 ===")
    result = processor.process_link("https://v.douyin.com/test123/", user_choice="C")
    print(result)
    
    # 测试 3：学习机制
    print("\n=== 测试 3：学习机制 ===")
    for i in range(3):
        result = processor.process_link("https://v.douyin.com/test123/", user_choice="C")
        print(f"第 {i+1} 次：{result.get('learning')}")


if __name__ == "__main__":
    main()
