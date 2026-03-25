# 学习机制详解

## 两种学习通道

### Explicit（明确偏好）

**触发词**：
- "Always do X"
- "From now on, X"
- "Never do Y"
- "I prefer X"
- "Remember that I always X"

**处理流程**：
```
用户说："Always use full analysis"
    ↓
检测到明确偏好
    ↓
直接写入 GLOBAL 或 PROJECT
    ↓
无需确认
```

**示例**：
```python
result = learner.detect_explicit_preference("Always use full analysis for douyin")
if result:
    learner.record_correction(
        key="douyin_default_action",
        value="full_analysis",
        context="用户明确表达",
        source="explicit"
    )
    # 输出：✅ 已确认偏好：douyin_default_action = full_analysis（明确表达）
```

---

### Implicit（隐式偏好）

**触发场景**：
- 用户纠正你 3 次（标准通道）
- 用户连续 5 次选择相同选项（快速通道）

**处理流程**：

#### 标准通道（3 次）

```
用户第 1 次纠正："No, use C"
    ↓
记录到 corrections.json（1/3）
    ↓
输出："已记录偏好候选：full_analysis（1/3）"

用户第 2 次纠正："Actually, use C"
    ↓
更新计数（2/3）
    ↓
输出："已记录偏好候选：full_analysis（2/3）"

用户第 3 次纠正："Why do you keep asking? Use C"
    ↓
计数达到 3 次
    ↓
询问："你已连续 3 次选择 '完整分析'。是否设为默认？"
    ↓
用户确认："Yes"
    ↓
写入 GLOBAL 或 PROJECT
```

#### 快速通道（5 次）

```
用户连续 5 次选择 C（7 天内）
    ↓
自动写入（无需确认）
    ↓
输出："✅ 已自动确认偏好：full_analysis（5 次相同操作）"
```

---

## Decay 机制

### 自动降级

```
30 天未用 → 降级到 WARM（PROJECT → ARCHIVE）
90 天未用 → 归档到 COLD
```

### 手动清除

```
用户说："Forget X"
    ↓
从所有层级移除
    ↓
询问："要导出备份吗？"
```

---

## 代码实现

### PreferenceLearner

```python
class PreferenceLearner:
    def __init__(self, corrections_file: str, memory_file: str):
        self.corrections_file = Path(corrections_file)
        self.memory_file = Path(memory_file)
        self.corrections: List[Correction] = []
        self.load_corrections()
    
    def detect_explicit_preference(self, user_input: str) -> Optional[Dict]:
        """检测明确偏好"""
        triggers = [
            ("always", r"always\s+(.+)"),
            ("from now on", r"from now on[, ]+(.+)"),
            ("never", r"never\s+(.+)"),
            ("prefer", r"i prefer\s+(.+)"),
            ("remember", r"remember that i always\s+(.+)"),
        ]
        
        for trigger_type, pattern in triggers:
            match = re.search(pattern, user_input.lower())
            if match:
                return {
                    "type": "explicit",
                    "trigger": trigger_type,
                    "value": match.group(1).strip(),
                    "raw": user_input
                }
        
        return None
    
    def detect_implicit_correction(self, user_input: str, context: str) -> Optional[Dict]:
        """检测隐式纠正"""
        triggers = [
            r"no[, ]+(that's not right|that's wrong)",
            r"actually[, ]+(it should be|use)",
            r"you're wrong",
            r"i prefer .+, not",
            r"stop (doing|using)",
            r"why do you keep",
        ]
        
        for pattern in triggers:
            if re.search(pattern, user_input.lower()):
                return {
                    "type": "implicit",
                    "context": context,
                    "raw": user_input
                }
        
        return None
    
    def record_correction(self, key: str, value: str, context: str, source: str = "implicit") -> Dict:
        """记录纠正"""
        # 检查是否有重复的纠正（7 天内）
        recent_corrections = [
            c for c in self.corrections
            if c.key == key
            and self._is_recent(c.timestamp, days=7)
        ]
        
        if recent_corrections:
            correction = recent_corrections[0]
            correction.count += 1
            correction.timestamp = datetime.now().isoformat()
            
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
```

---

## 统计

### 查看学习统计

```python
stats = learner.get_stats()
# {
#   "total": 10,
#   "confirmed": 3,
#   "pending": 7,
#   "recent_7d": 5
# }
```

---

## 最佳实践

1. **明确偏好优先**：鼓励用户说 "Always X"
2. **不要过度询问**：让 3 次机制工作
3. **快速通道**：5 次自动确认（减少打扰）
4. **定期清理**：30/90 天 Decay

---

## 相关文档

- `config-system.md`：配置系统详解
- `workflow.md`：工作流详解
