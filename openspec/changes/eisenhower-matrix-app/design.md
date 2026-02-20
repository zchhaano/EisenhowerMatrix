# Eisenhower Matrix App - Technical Design

## Context

### Background
基于可行性调研，艾森豪威尔矩阵应用市场高度分散，尚未出现垄断玩家。现有竞品痛点：
- 分类摩擦导致决策瘫痪
- 缺乏执行驱动力，任务堆积如山
- 商业化体验割裂（过度广告）
- UI/UX设计僵化，移动端体验差

### Core Positioning
**简洁易用的AI赋能效率工具** —— 对抗人类"纯粹紧急效应"本能，帮助用户聚焦重要事务。

### Constraints
- MVP预算：$30,000 - $60,000
- 开发周期：3-4个月
- 团队规模：小型跨职能团队
- AI成本需可控（Token消耗监控）

## Goals / Non-Goals

**Goals:**
- 跨平台覆盖 (iOS/Android/Web) 单一代码库
- 离线优先架构，毫秒级响应
- AI智能辅助降低认知负荷
- 游戏化机制提升留存率
- 混合变现模型（免费+买断+AI订阅）

**Non-Goals:**
- B2B团队协作功能（MVP后期考虑）
- 复杂项目管理（甘特图、里程碑）
- 第三方日历深度集成（MVP范围外）
- 桌面端原生应用（Web版覆盖）

## Decisions

### D1: 跨平台框架选择 → Flutter

**Rationale:**
- 自渲染引擎确保UI一致性（60fps/120fps动画）
- 单代码库编译iOS/Android/Web
- 46%跨平台开发者份额，生态成熟
- 折叠屏设备适配优秀

**Alternatives Considered:**
- React Native: Web背景团队友好，但动画性能略逊
- Kotlin Multiplatform: 原生体验好，但Web支持弱
- 原生开发: 成本翻倍，维护负担重

### D2: 后端架构 → Supabase (PostgreSQL)

**Rationale:**
- 关系型数据库更适合任务/子任务/标签层级结构
- 行级安全(RLS)策略简化权限管理
- 内置Auth/Storage/Edge Functions，减少集成成本
- 定价透明可控，避免Firebase"天价账单"风险

**Alternatives Considered:**
- Firebase: NoSQL查询复杂关系效率低，SDK臃肿
- 自建后端: 开发周期延长，MVP不划算

### D3: 离线优先架构

**架构模式:**
```
[Local DB (SQLite)] ←→ [Sync Engine] ←→ [Supabase Cloud]
        ↑                      ↓
   [UI Layer]           [Conflict Resolution]
```

**关键实现:**
- 本地SQLite作为primary data source
- WatermelonDB处理离线CRUD和同步
- CRDT-inspired冲突解决（last-write-wins + 客户端时间戳）
- 后台增量同步，用户无感知

### D4: AI集成策略

**成本控制机制:**
- 免费用户：20次AI调用/月
- 付费用户：100次AI调用/月
- 超出后需购买"AI效率包"
- Token使用监控（Prompts.ai或自建）

**AI功能优先级:**
1. P0: 智能任务分类（必须）
2. P1: 任务拆解建议
3. P2: 伪紧急识别
4. P3: 年度总结生成

### D5: 变现模式 → 混合制

| 层级 | 价格 | 包含功能 |
|------|------|----------|
| Free | $0 | 无限任务、四象限视图、本地存储 |
| Lifetime | $29-49 | 云同步、主题定制、数据报表 |
| AI Pack | $3.99/次 | 100次AI调用 |
| Pro AI | $4.99/月 | 无限AI调用 + 优先功能 |

**Web-to-App支付:** 引导用户网页付费，规避15-30%平台抽成

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| AI成本失控 | Token监控 + 硬预算上限 + 按量付费 |
| 用户留存低 | 游戏化机制 + 优质Onboarding + 推送召回 |
| 竞品快速复制 | 聚焦AI差异化 + 建立用户习惯护城河 |
| 离线同步冲突 | CRDT算法 + 冲突提示UI + 手动解决选项 |
| 跨平台性能差异 | Flutter统一渲染 + 针对性性能测试 |
| 应用商店审核 | 遵循指南 + Web支付引导谨慎措辞 |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────┬─────────────┬─────────────┬──────────────┤
│  UI Layer   │ State Mgmt  │ Local DB    │ Sync Engine  │
│  (Widgets)  │ (Riverpod)  │ (SQLite)    │ (Offline-1st)│
├─────────────┴─────────────┴─────────────┴──────────────┤
│                    Services Layer                       │
├─────────────┬─────────────┬─────────────┬──────────────┤
│ TaskService │ AIService   │ Gamification│ Analytics    │
└─────────────┴─────────────┴─────────────┴──────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Supabase Backend                     │
├─────────────┬─────────────┬─────────────┬──────────────┤
│ PostgreSQL  │ Auth        │ Storage     │ Edge Funcs   │
│ (RLS)       │ (OAuth)     │ (Exports)   │ (AI Proxy)   │
└─────────────┴─────────────┴─────────────┴──────────────┘
```

## Data Model (Core Entities)

```sql
-- 用户
users (id, email, created_at, subscription_tier, ai_tokens_remaining)

-- 任务
tasks (
  id, user_id, title, description,
  quadrant (1-4), priority, status,
  due_date, completed_at,
  parent_task_id, -- 子任务支持
  created_at, updated_at
)

-- 标签
tags (id, user_id, name, color)

-- 任务标签关联
task_tags (task_id, tag_id)

-- 游戏化记录
gamification_logs (id, user_id, action, points, created_at)

-- 同步元数据
sync_metadata (id, entity_type, entity_id, version, synced_at)
```

## Open Questions

1. **AI模型选择**: 使用OpenAI API vs 自建模型？需评估成本/质量/延迟
2. **推送策略**: 本地推送 vs 远程推送优先级？
3. **数据导出格式**: 仅JSON vs 支持CSV/PDF？
4. **国际化**: MVP是否包含多语言支持？

## Migration Plan

### Phase 1: MVP Launch (Week 1-12)
- 核心四象限功能
- 基础AI分类
- 本地存储 + 简单云同步
- 免费版 + Lifetime付费

### Phase 2: Enhancement (Week 13-16)
- 完整游戏化系统
- 高级AI功能
- 数据分析报表
- AI订阅上线

### Rollback Strategy
- 前端: 版本回退 + 强制更新提示
- 后端: Supabase分支回滚
- 数据: 每日备份 + 时间点恢复
