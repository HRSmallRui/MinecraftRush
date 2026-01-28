extends SummonBlock
class_name EnemySummonBlock

enum EnemyID{
	尸国杂兵 = 0,
	尸国皮甲兵 = 1,
	尸国小鬼 = 2,
	鸡骑士 = 3,
	尸国正规军 = 4,
	尸国壮汉 = 5,
	尸国刺杀者 = 6,
	尸国贵族战士 = 7,
	骨国步兵 = 8,
	骨国正规军 = 9,
	尸国统帅 = 54,
}

@export var enemy_id: EnemyID
@export var summon_count:int = 1 ##生成数量
@export var time_interval: float ##生成间隔时间
