#!/usr/bin/env python3
"""
Content Inbox 测试脚本
用现有的三个抖音链接测试完整流程
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from process_link import ContentInboxProcessor
from logger import setup_logger, log_processing, log_user_choice

# 测试链接（已下载）
TEST_LINKS = [
    {
        "url": "https://v.douyin.com/vH931iPlYbU/",
        "platform": "douyin",
        "tag": "果糖/健身",
        "file": "水果=果糖？，十恶不赦？千万别吃？ 2026年了，... .mp4"
    },
    {
        "url": "https://v.douyin.com/_snNCwj7L5I/",
        "platform": "douyin",
        "tag": "情感",
        "file": "难怪撒贝宁都嫉妒何炅，何老师一开口我就想哭了.mp4"
    },
    {
        "url": "https://v.douyin.com/ZopDRPkbfoU/",
        "platform": "douyin",
        "tag": "脑科学/心理学",
        "file": "用第二人格帮你进入状态 #脑科学#青年创作者成长计划.mp4"
    }
]


def test_platform_detection():
    """测试平台检测"""
    print("\n=== 测试 1：平台检测 ===")
    
    processor = ContentInboxProcessor()
    
    for link in TEST_LINKS:
        url = link["url"]
        expected = link["platform"]
        
        # 模拟用户消息
        message = f"帮我下载这个：{url}"
        
        # 检测平台
        detected = processor.detect_platform(message)
        
        status = "✅" if detected == expected else "❌"
        print(f"{status} {link['tag']}: {detected} (期望: {expected})")
        
        # 提取 URL
        extracted = processor.extract_url(message, detected)
        print(f"   URL: {extracted}")


def test_config_system():
    """测试配置系统"""
    print("\n=== 测试 2：配置系统 ===")
    
    processor = ContentInboxProcessor()
    
    # 测试默认配置
    default = processor.get_default_action("douyin")
    print(f"默认动作（抖音）: {default}")
    
    # 测试设置配置
    processor.config.set("douyin_default_action", "C", layer="session")
    new_value = processor.get_default_action("douyin")
    print(f"设置后（SESSION）: {new_value}")
    
    # 测试配置层级
    info = processor.config.get_layer_info("douyin_default_action")
    print(f"配置来源: {info.get('source', 'SKILL')}")


def test_learning_mechanism():
    """测试学习机制"""
    print("\n=== 测试 3：学习机制 ===")
    
    processor = ContentInboxProcessor()
    
    # 模拟用户连续 3 次选择 C
    print("模拟用户连续 3 次选择 'C'...")
    
    for i in range(3):
        result = processor.record_user_choice("douyin", "C")
        print(f"  第 {i+1} 次: {result['action']} | 计数: {result.get('count')} | {result['message']}")
    
    # 模拟用户连续 5 次（快速通道）
    print("\n模拟用户连续 5 次选择 'B'...")
    
    # 清除之前的记录
    processor.learner.corrections = []
    processor.learner.save_corrections()
    
    for i in range(5):
        result = processor.record_user_choice("douyin", "B")
        print(f"  第 {i+1} 次: {result['action']} | 计数: {result.get('count')}")
        
        if result['action'] == 'auto_confirm':
            print(f"  ✅ 快速通道触发！自动写入偏好")
            break


def test_full_workflow():
    """测试完整工作流"""
    print("\n=== 测试 4：完整工作流 ===")
    
    processor = ContentInboxProcessor()
    
    for i, link in enumerate(TEST_LINKS, 1):
        print(f"\n--- 测试链接 {i}: {link['tag']} ---")
        
        # 模拟用户消息
        message = f"帮我处理这个：{link['url']}"
        
        # 处理链接（无用户选择）
        result = processor.process_link(message)
        
        print(f"动作: {result['action']}")
        print(f"平台: {result.get('platform')}")
        print(f"URL: {result.get('url')}")
        
        if result['action'] == 'ask':
            print("询问用户...")
            print(result['message'])
            
            # 模拟用户选择 C
            user_choice = "C"
            result = processor.process_link(message, user_choice=user_choice)
            
            print(f"\n用户选择: {user_choice}")
            print(f"新动作: {result['action']}")
            print(f"SubAgent 任务: {result.get('task')}")
            print(f"学习结果: {result.get('learning')}")


def test_explicit_preference():
    """测试明确偏好"""
    print("\n=== 测试 5：明确偏好（Explicit）===")
    
    processor = ContentInboxProcessor()
    
    # 模拟用户说 "Always use C"
    explicit_text = "Always use full analysis for douyin"
    
    result = processor.learner.detect_explicit_preference(explicit_text)
    
    if result:
        print(f"✅ 检测到明确偏好: {result}")
        
        # 记录
        learning_result = processor.learner.record_correction(
            key="douyin_default_action",
            value="C",
            context="用户明确表达",
            source="explicit"
        )
        
        print(f"学习结果: {learning_result}")
    else:
        print("❌ 未检测到明确偏好")


def test_metrics():
    """测试统计信息"""
    print("\n=== 测试 6：统计信息 ===")
    
    processor = ContentInboxProcessor()
    
    stats = processor.learner.get_stats()
    print(f"学习统计: {stats}")


def main():
    """运行所有测试"""
    logger = setup_logger()
    logger.info("开始 Content Inbox 测试")
    
    print("=" * 60)
    print("Content Inbox 测试套件")
    print("=" * 60)
    
    try:
        test_platform_detection()
        test_config_system()
        test_learning_mechanism()
        test_full_workflow()
        test_explicit_preference()
        test_metrics()
        
        print("\n" + "=" * 60)
        print("✅ 所有测试完成")
        print("=" * 60)
        
        logger.info("所有测试完成")
        
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")
        logger.error(f"测试失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
