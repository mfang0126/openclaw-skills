#!/usr/bin/env python3
"""
Content Inbox 日志系统
"""

import logging
import os
from datetime import datetime
from pathlib import Path


def setup_logger(name: str = "content-inbox", log_dir: str = None):
    """
    设置日志系统
    
    Args:
        name: 日志名称
        log_dir: 日志目录
    
    Returns:
        logger 对象
    """
    # 默认日志目录
    if not log_dir:
        log_dir = os.path.expanduser("~/.openclaw/workspace/skills/content-inbox/data")
    
    os.makedirs(log_dir, exist_ok=True)
    
    # 创建 logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    
    # 避免重复添加 handler
    if logger.handlers:
        return logger
    
    # 文件日志（按日期）
    log_file = os.path.join(
        log_dir, 
        f"content-inbox-{datetime.now().strftime('%Y-%m-%d')}.log"
    )
    
    fh = logging.FileHandler(log_file, encoding='utf-8')
    fh.setLevel(logging.INFO)
    
    # 控制台日志
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    
    # 格式
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)
    
    logger.addHandler(fh)
    logger.addHandler(ch)
    
    return logger


# 全局 logger
logger = setup_logger()


def log_processing(platform: str, url: str, action: str, result: str):
    """
    记录处理事件
    
    Args:
        platform: 平台
        url: 链接
        action: 动作
        result: 结果
    """
    logger.info(f"处理链接 | 平台: {platform} | 动作: {action} | 结果: {result} | URL: {url}")


def log_user_choice(platform: str, choice: str, learning_result: dict):
    """
    记录用户选择
    
    Args:
        platform: 平台
        choice: 用户选择
        learning_result: 学习结果
    """
    logger.info(
        f"用户选择 | 平台: {platform} | 选择: {choice} | "
        f"学习状态: {learning_result.get('action')} | "
        f"计数: {learning_result.get('count')}"
    )


def log_error(platform: str, url: str, error: str):
    """
    记录错误
    
    Args:
        platform: 平台
        url: 链接
        error: 错误信息
    """
    logger.error(f"处理失败 | 平台: {platform} | 错误: {error} | URL: {url}")


def log_config_change(key: str, old_value: str, new_value: str, layer: str):
    """
    记录配置变更
    
    Args:
        key: 配置键
        old_value: 旧值
        new_value: 新值
        layer: 层级
    """
    logger.info(
        f"配置变更 | 键: {key} | 旧值: {old_value} | 新值: {new_value} | 层级: {layer}"
    )


if __name__ == "__main__":
    # 测试日志
    logger.info("测试日志系统")
    
    log_processing("douyin", "https://v.douyin.com/test/", "download", "success")
    log_user_choice("douyin", "C", {"action": "pending", "count": 1})
    log_error("douyin", "https://v.douyin.com/test/", "下载失败")
    log_config_change("douyin_default_action", "ask", "C", "GLOBAL")
    
    print("✅ 日志测试完成")
