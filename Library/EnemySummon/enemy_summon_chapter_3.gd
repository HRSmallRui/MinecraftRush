@tool
extends SummonBlock
class_name EnemySummonBlockChapter3


enum EnemyID{
	xx = 0,
	尸壳 = 19,
	尸壳勇士 = 20,
	沙漠狙击手 = 21,
	蠹虫 = 22,
	噩梦幻翼 = 23,
	沙漠守卫 = 24,
	木乃伊 = 25,
	黄金傀儡 = 26,
	沙漠雇佣兵 = 27,
	军火商 = 28,
	巨型尸壳 = 56
}

@export var enemy_id: EnemyID = EnemyID.尸壳
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
