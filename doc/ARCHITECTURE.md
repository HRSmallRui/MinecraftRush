# MinecraftRush — 工程架构说明

> 📌 本文档目前为占位状态，详细内容将在后续整理后补充。

---

## 当前状态

- 本工程为 MinecraftRush 1.0 版本的完整源码
- 架构说明正在整理中，目前可先通过浏览目录结构了解工程组织方式

---

## 📁 目录结构（概览）

```
根目录/
├── Assets/ # 美术/音效资源
│ ├── Animations/ # 动画文件
│ ├── Fonts/ # 字体
│ ├── Images/ # 图片素材
│ ├── Resources/ # 资源文件
│ ├── Shaders/ # 着色器
│ ├── Sounds/ # 音效
│ └── Videos/ # 视频
│
├── Library/ # 数据配置（当初业务能力不熟练，拿来当数据库用了，里面全是 static 变量）
│ ├── Achievements/ # 成就结构体 + Library 类（内含静态数组）
│ ├── DefenceTowers/ # 防御塔数据配置
│ ├── Enemies/ # 敌人数据配置
│ ├── EnemySummon/ # 出怪配置文件基类（供嵌套用）
│ ├── ExtraLibrary/ # 额外菜单介绍内容配置文件
│ ├── Heroes/ # 英雄数据文件（早期有 HeroLibrary，已废弃）
│ └── SummonConfigs/ # 各关卡出怪配置文件
│
├── Savs/ # 存档系统
│ ├── GameSaver.gd # 游戏存档
│ └── UserSaver.gd # 用户设置存档
│ # debug 模式用 Savs 目录下的存档，release 版用 user:// 目录的存档
│
├── Scenes/ # 所有场景文件
│ ├── Allys/ # 友方单位场景
│ ├── Autoloads/ # 自动加载单例场景
│ ├── Buffs/ # 增益效果场景
│ ├── Bullets/ # 子弹/弹丸场景
│ ├── Classes/ # 职业/类型相关场景
│ ├── DefenceTowers/ # 防御塔场景
│ ├── Effects/ # 特效场景
│ ├── Enemies/ # 敌人场景
│ ├── GameBased/ # 游戏核心场景
│ ├── Skills/ # 技能场景
│ ├── StageComponents/ # 关卡组件
│ ├── Stages/ # 各关卡场景
│ ├── TipUI/ # 提示界面
│ ├── TowerBuffs/ # 塔增益场景
│ └── UI-Components/ # UI 组件
│
├── Scripts/ # 所有脚本
│
└── Translations/ # 多语言翻译文件
```


（具体目录结构以实际仓库为准，此处为当前工程布局概览）

---

## 🧩 核心模块说明（待补充）

- **怪物系统**：`Scenes/Enemies/` + `Library/Enemies/`
- **塔防系统**：`Scenes/DefenceTowers/` + `Library/DefenceTowers/`
- **波次管理**：`Library/SummonConfigs/` + `Library/EnemySummon/`
- **存档系统**：`Savs/`（debug 用本地，release 用 user://）
- **成就系统**：`Library/Achievements/`
- **英雄系统**：`Library/Heroes/`（早期版本遗留）

---

## 📝 待补充内容

- 各模块的职责说明
- 关键脚本的调用关系
- 数据流向示意

---

*本文档会逐步完善，欢迎持续关注*
