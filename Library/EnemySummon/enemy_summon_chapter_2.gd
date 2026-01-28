@tool
extends SummonBlock
class_name EnemySummonBlockChapter2


enum EnemyID{
	xx = 0,
	野区丧尸 = 10,
	溺尸 = 11,
	溺尸斗士 = 12,
	腐化苦力怕 = 13,
	腐化蜘蛛 = 14,
	终末 = 15,
	野狼 = 16,
	丛林幻翼 = 17,
	腐朽 = 18,
	泰坦丧尸 = 55
}

@export var enemy_id: EnemyID = EnemyID.野区丧尸
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
