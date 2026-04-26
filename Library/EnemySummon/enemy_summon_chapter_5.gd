@tool
extends SummonBlock
class_name EnemySummonBlockChapter5


enum EnemyID{
	xx = 0,
	白眼士兵 = 45,
	白眼勇士 = 46,
	白眼法师 = 47,
	白眼傀儡 = 48,
	LIVER = 58
}

@export var enemy_id: EnemyID = EnemyID.白眼士兵
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
