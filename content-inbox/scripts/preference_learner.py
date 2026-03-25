#!/usr/bin/env python3
"""
用户偏好学习机制
- Explicit（明确偏好）：直接写入
- Implicit（隐式偏好）：3 次确认后写入
"""

import json
import os
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict

@dataclass
class Correction:
    """纠正记录"""
    key: str
    value: str
    context: str
    timestamp: str
    count: int = 1
    confirmed: bool = False
    source: str = "implicit"  # explicit | implicit

class PreferenceLearner:
    """偏好学习器"""
    
    def __init__(self, corrections_file: str, memory_file: str):
        self.corrections_file = Path(corrections_file)
        self.memory_file = Path(memory_file)
        self.corrections: List[Correction] = []
        self.load_corrections()
    
    def load_corrections(self):
        """加载纠正记录"""
        if not self.corrections_file.exists():
            return
        
        with open(self.corrections_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            self.corrections = [Correction(**item) for item in data]
    
    def save_corrections(self):
        """保存纠正记录"""
        self.corrections_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(self.corrections_file, 'w', encoding='utf-8') as f:
            json.dump([asdict(c) for c in self.corrections], f, ensure_ascii=False, indent=2)
    
    def detect_explicit_preference(self, user_input: str) -> Optional[Dict]:
        """
        检测明确偏好
        
        触发词：
        - "Always do X"
        - "From now on, X"
        - "Never do Y"
        - "I prefer X"
        - "Remember that I always X"
        """
        triggers = [
            ("always", r"always\s+(.+)"),
            ("from now on", r"from now on[, ]+(.+)"),
            ("never", r"never\s+(.+)"),
            ("prefer", r"i prefer\s+(.+)"),
            ("remember", r"remember that i always\s+(.+)"),
        ]
        
        import re
        user_input_lower = user_input.lower()
        
        for trigger_type, pattern in triggers:
            match = re.search(pattern, user_input_lower)
            if match:
                return {
                    "type": "explicit",
                    "trigger": trigger_type,
                    "value": match.group(1).strip(),
                    "raw": user_input
                }
        
        return None
    
    def detect_implicit_correction(self, user_input: str, context: str) -> Optional[Dict]:
        """
        检测隐式纠正
        
        触发词：
        - "No, that's not right..."
        - "Actually, it should be..."
        - "You're wrong about..."
        - "I prefer X, not Y"
        - "Stop doing X"
        - "Why do you keep..."
        """
        triggers = [
            r"no[, ]+(that's not right|that's wrong)",
            r"actually[, ]+(it should be|use)",
            r"you're wrong",
            r"i prefer .+, not",
            r"stop (doing|using)",
            r"why do you keep",
            r"i said",
            r"don't",
        ]
        
        import re
        user_input_lower = user_input.lower()
        
        for pattern in triggers:
            if re.search(pattern, user_input_lower):
                return {
                    "type": "implicit",
                    "context": context,
                    "raw": user_input
                }
        
        return None
    
    def record_correction(self, key: str, value: str, context: str, source: str = "implicit") -> Dict:
        """
        记录纠正
        
        Returns:
            {
                "action": "confirm" | "pending" | "auto_confirm",
                "count": int,
                "message": str
            }
        """
        # 检查是否有重复的纠正（7 天内）
        recent_corrections = [
            c for c in self.corrections
            if c.key == key
            and self._is_recent(c.timestamp, days=7)
        ]
        
        if recent_corrections:
            # 更新计数
            correction = recent_corrections[0]
            correction.count += 1
            correction.timestamp = datetime.now().isoformat()
            
            # 检查是否达到阈值
            if source == "explicit":
                # 明确偏好：直接确认
                correction.confirmed = True
                correction.source = "explicit"
                self._write_to_memory(key, value, source="explicit")
                self.save_corrections()
                return {
                    "action": "auto_confirm",
                    "count": correction.count,
                    "message": f"✅ 已确认偏好：{key} = {value}（明确表达）"
                }
            
            if correction.count >= 5:
                # 快速通道：5 次自动确认
                correction.confirmed = True
                self._write_to_memory(key, value, source="implicit_fast")
                self.save_corrections()
                return {
                    "action": "auto_confirm",
                    "count": correction.count,
                    "message": f"✅ 已自动确认偏好：{key} = {value}（5 次相同操作）"
                }
            
            if correction.count >= 3:
                # 标准通道：3 次询问确认
                self.save_corrections()
                return {
                    "action": "confirm",
                    "count": correction.count,
                    "message": f"你已连续 {correction.count} 次选择 '{value}'。是否设为默认？"
                }
            
            # 未达到阈值
            self.save_corrections()
            return {
                "action": "pending",
                "count": correction.count,
                "message": f"已记录偏好候选：{key} = {value}（{correction.count}/3）"
            }
        
        else:
            # 新纠正
            correction = Correction(
                key=key,
                value=value,
                context=context,
                timestamp=datetime.now().isoformat(),
                count=1,
                confirmed=False,
                source=source
            )
            self.corrections.append(correction)
            self.save_corrections()
            
            return {
                "action": "pending",
                "count": 1,
                "message": f"已记录偏好候选：{key} = {value}（1/3）"
            }
    
    def confirm_preference(self, key: str, scope: str = "global"):
        """
        确认偏好
        
        Args:
            key: 配置键
            scope: "global" | "project" | "session"
        """
        for correction in self.corrections:
            if correction.key == key and not correction.confirmed:
                correction.confirmed = True
                self._write_to_memory(key, correction.value, source=scope)
        
        self.save_corrections()
    
    def _write_to_memory(self, key: str, value: str, source: str):
        """写入记忆文件"""
        self.memory_file.parent.mkdir(parents=True, exist_ok=True)
        
        # 读取现有内容
        if self.memory_file.exists():
            with open(self.memory_file, 'r', encoding='utf-8') as f:
                content = f.read()
        else:
            content = "# Self-Improving Memory\n\n## Confirmed Preferences\n"
        
        # 添加新偏好
        timestamp = datetime.now().strftime("%Y-%m-%d")
        new_entry = f"- {key}: {value} (confirmed {timestamp}, source: {source})\n"
        
        # 插入到 Confirmed Preferences 部分
        if "## Confirmed Preferences" in content:
            lines = content.split('\n')
            insert_index = None
            for i, line in enumerate(lines):
                if line.startswith("## Confirmed Preferences"):
                    insert_index = i + 1
                    # 跳过已有的同名配置
                    while insert_index < len(lines) and lines[insert_index].startswith(f"- {key}:"):
                        lines.pop(insert_index)
                    break
            
            if insert_index:
                lines.insert(insert_index, new_entry)
                content = '\n'.join(lines)
        else:
            content += f"\n## Confirmed Preferences\n{new_entry}"
        
        # 写回文件
        with open(self.memory_file, 'w', encoding='utf-8') as f:
            f.write(content)
    
    def _is_recent(self, timestamp: str, days: int = 7) -> bool:
        """检查时间戳是否在最近 N 天内"""
        try:
            ts = datetime.fromisoformat(timestamp)
            return datetime.now() - ts < timedelta(days=days)
        except:
            return False
    
    def get_stats(self) -> Dict:
        """获取统计信息"""
        total = len(self.corrections)
        confirmed = sum(1 for c in self.corrections if c.confirmed)
        pending = total - confirmed
        
        recent_7d = sum(
            1 for c in self.corrections
            if self._is_recent(c.timestamp, days=7)
        )
        
        return {
            "total": total,
            "confirmed": confirmed,
            "pending": pending,
            "recent_7d": recent_7d
        }


# 使用示例
if __name__ == "__main__":
    learner = PreferenceLearner(
        corrections_file="~/.openclaw/workspace/content-inbox/data/corrections.json",
        memory_file="~/.openclaw/memory.md"
    )
    
    # 测试明确偏好
    result = learner.detect_explicit_preference("Always use full analysis for douyin videos")
    if result:
        print(f"检测到明确偏好：{result}")
        learner.record_correction(
            key="douyin_default_action",
            value="full_analysis",
            context="用户明确表达",
            source="explicit"
        )
    
    # 测试隐式纠正
    result = learner.detect_implicit_correction(
        "No, that's not right. Use full analysis.",
        context="抖音视频处理"
    )
    if result:
        print(f"检测到隐式纠正：{result}")
        learner.record_correction(
            key="douyin_default_action",
            value="full_analysis",
            context="抖音视频处理",
            source="implicit"
        )
    
    # 查看统计
    print(f"统计：{learner.get_stats()}")
