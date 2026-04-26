@tool
extends SummonBlock
class_name EnemySummonBlockChapter6


enum EnemyID{
	xx = 0,
	尸国斗剑士 = 49,
	剧毒蜘蛛 = 50,
	荆棘射手 = 51,
	厌国投弹手 = 52,
	戮 = 53
}

@export var enemy_id: EnemyID = EnemyID.尸国斗剑士
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
