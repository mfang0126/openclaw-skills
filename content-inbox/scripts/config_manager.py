#!/usr/bin/env python3
"""
4 层配置系统
SESSION → PROJECT → GLOBAL → SKILL
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, Optional
from datetime import datetime, timedelta

class ConfigLayer:
    """配置层级基类"""
    
    def __init__(self, name: str, path: str, priority: int):
        self.name = name
        self.path = Path(path)
        self.priority = priority
        self.data = {}
        
    def load(self) -> Dict:
        """加载配置"""
        if not self.path.exists():
            return {}
        
        if self.path.suffix == '.json':
            with open(self.path, 'r', encoding='utf-8') as f:
                self.data = json.load(f)
        elif self.path.suffix == '.md':
            self.data = self._parse_md(self.path)
        
        return self.data
    
    def save(self, data: Dict):
        """保存配置"""
        self.path.parent.mkdir(parents=True, exist_ok=True)
        
        if self.path.suffix == '.json':
            with open(self.path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        elif self.path.suffix == '.md':
            self._write_md(self.path, data)
        
        self.data = data
    
    def _parse_md(self, path: Path) -> Dict:
        """解析 markdown 配置"""
        # 简化实现：只解析关键行
        data = {}
        with open(path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('- ') and ':' in line:
                    key, value = line[2:].split(':', 1)
                    data[key.strip()] = value.strip()
        return data
    
    def _write_md(self, path: Path, data: Dict):
        """写入 markdown 配置"""
        with open(path, 'w', encoding='utf-8') as f:
            f.write(f"# {self.name} Config\n\n")
            f.write(f"Updated: {datetime.now().isoformat()}\n\n")
            for key, value in data.items():
                f.write(f"- {key}: {value}\n")


class SessionLayer(ConfigLayer):
    """SESSION 层（临时偏好，单次对话）"""
    
    def __init__(self, base_dir: str):
        super().__init__(
            name="SESSION",
            path=os.path.join(base_dir, "content-inbox/data/session.json"),
            priority=1
        )
    
    def clear(self):
        """清除临时偏好"""
        self.save({})
    
    def set_temp_preference(self, key: str, value: Any, reason: str = ""):
        """设置临时偏好"""
        self.load()
        self.data[key] = {
            "value": value,
            "reason": reason,
            "created_at": datetime.now().isoformat()
        }
        self.save(self.data)


class ProjectLayer(ConfigLayer):
    """PROJECT 层（项目特定配置）"""
    
    def __init__(self, base_dir: str, project_name: str):
        super().__init__(
            name=f"PROJECT:{project_name}",
            path=os.path.join(base_dir, f"projects/{project_name}/config.md"),
            priority=2
        )
        self.project_name = project_name


class GlobalLayer(ConfigLayer):
    """GLOBAL 层（全局偏好）"""
    
    def __init__(self, home_dir: str):
        super().__init__(
            name="GLOBAL",
            path=os.path.join(home_dir, ".openclaw/memory.md"),
            priority=3
        )


class SkillLayer(ConfigLayer):
    """SKILL 层（默认行为）"""
    
    def __init__(self, skill_path: str):
        super().__init__(
            name="SKILL",
            path=skill_path,
            priority=4
        )


class ConfigManager:
    """4 层配置管理器"""
    
    def __init__(self, workspace_dir: str, home_dir: str, current_project: Optional[str] = None):
        self.workspace_dir = workspace_dir
        self.home_dir = home_dir
        self.current_project = current_project
        
        # 初始化 4 层
        self.session = SessionLayer(workspace_dir)
        self.project = ProjectLayer(workspace_dir, current_project) if current_project else None
        self.global_layer = GlobalLayer(home_dir)
        self.skill_layer = None  # 动态设置
        
        # 加载所有配置
        self.reload()
    
    def reload(self):
        """重新加载所有配置"""
        self.session.load()
        if self.project:
            self.project.load()
        self.global_layer.load()
        if self.skill_layer:
            self.skill_layer.load()
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        获取配置值（按优先级查找）
        SESSION → PROJECT → GLOBAL → SKILL
        """
        # 1. SESSION 层
        if key in self.session.data:
            return self.session.data[key].get("value")
        
        # 2. PROJECT 层
        if self.project and key in self.project.data:
            return self.project.data[key]
        
        # 3. GLOBAL 层
        if key in self.global_layer.data:
            return self.global_layer.data[key]
        
        # 4. SKILL 层
        if self.skill_layer and key in self.skill_layer.data:
            return self.skill_layer.data[key]
        
        return default
    
    def set(self, key: str, value: Any, layer: str = "global"):
        """
        设置配置值
        
        Args:
            key: 配置键
            value: 配置值
            layer: 目标层级（session/project/global）
        """
        if layer == "session":
            self.session.set_temp_preference(key, value)
        elif layer == "project":
            if not self.project:
                raise ValueError("No project context")
            self.project.load()
            self.project.data[key] = value
            self.project.save(self.project.data)
        elif layer == "global":
            self.global_layer.load()
            self.global_layer.data[key] = {
                "value": value,
                "confirmed_at": datetime.now().isoformat()
            }
            self.global_layer.save(self.global_layer.data)
        else:
            raise ValueError(f"Unknown layer: {layer}")
    
    def get_all_configs(self) -> Dict[str, Any]:
        """获取所有配置（合并后）"""
        result = {}
        
        # 按优先级反向合并（低优先级先加载）
        if self.skill_layer:
            result.update(self.skill_layer.data)
        
        result.update(self.global_layer.data)
        
        if self.project:
            result.update(self.project.data)
        
        result.update(self.session.data)
        
        return result
    
    def get_layer_info(self, key: str) -> Dict:
        """获取配置值的层级信息"""
        info = {
            "key": key,
            "value": None,
            "source": None,
            "priority": None
        }
        
        if key in self.session.data:
            info["value"] = self.session.data[key].get("value")
            info["source"] = "SESSION"
            info["priority"] = 1
            info["reason"] = self.session.data[key].get("reason")
        elif self.project and key in self.project.data:
            info["value"] = self.project.data[key]
            info["source"] = "PROJECT"
            info["priority"] = 2
        elif key in self.global_layer.data:
            info["value"] = self.global_layer.data[key].get("value")
            info["source"] = "GLOBAL"
            info["priority"] = 3
            info["confirmed_at"] = self.global_layer.data[key].get("confirmed_at")
        elif self.skill_layer and key in self.skill_layer.data:
            info["value"] = self.skill_layer.data[key]
            info["source"] = "SKILL"
            info["priority"] = 4
        
        return info
    
    def clear_session(self):
        """清除 SESSION 层"""
        self.session.clear()
    
    def set_project(self, project_name: str):
        """切换项目"""
        self.current_project = project_name
        self.project = ProjectLayer(self.workspace_dir, project_name)
        self.project.load()


# 使用示例
if __name__ == "__main__":
    # 初始化配置管理器
    config = ConfigManager(
        workspace_dir="~/.openclaw/workspace",
        home_dir="~",
        current_project="accounting-ai"
    )
    
    # 获取配置
    default_action = config.get("douyin_default_action", "ask")
    print(f"Default action: {default_action}")
    
    # 设置临时偏好
    config.set("douyin_default_action", "download_only", layer="session")
    
    # 设置项目配置
    config.set("douyin_default_action", "generate_draft", layer="project")
    
    # 设置全局偏好
    config.set("douyin_default_action", "full_analysis", layer="global")
    
    # 查看层级信息
    info = config.get_layer_info("douyin_default_action")
    print(f"Config info: {info}")
