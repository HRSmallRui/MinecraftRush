@tool
extends SummonBlock
class_name EnemySummonBlockChapter4


enum EnemyID{
	xx = 0,
	厌国战士 = 29,
	厌国精英 = 30,
	苦力怕 = 31,
	厌国狂战士 = 32,
	劫掠者 = 33,
	卫道士 = 34,
	劫掠者队长 = 35,
	唤魔者 = 36,
	女巫 = 37,
	劫掠兽 = 38,
	史莱姆 = 39,
	幻翼 = 40,
	蜘蛛 = 41,
	恼鬼 = 42,
	泰坦威斯克 = 43,
	守卫者 = 44,
	远古守卫者= 57
}

@export var enemy_id: EnemyID = EnemyID.厌国战士
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
