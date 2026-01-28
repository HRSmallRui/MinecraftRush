@tool
extends Node2D
class_name SummonCountProcess

@export var switch_process: bool:
	set(v):
		switch_process = false
		count()

@export var loading_configs: bool:
	set(v):
		loading_configs = false
		load_configs()
@export var enemy_parnt_node: Node2D

@export var max_wave_count: int
@export var process_summon_blocks: Array[PathSummonList]


func _ready() -> void:
	if !Engine.is_editor_hint():
		count()
	pass


func enemy_id_to_string(enemy_id: int) -> String:
	match enemy_id:
		0: return "尸国杂兵"
		1: return "尸国皮甲兵"
		2: return "尸国小鬼"
		3: return "鸡骑士"
		4: return "尸国正规军"
		5: return "尸国壮汉"
		6: return "杀人狂魔"
		7: return "尸国贵族战士"
		8: return "骨国步兵"
		9: return "骨国正规军"
		
		10: return "野区丧尸"
		11: return "溺尸"
		12: return "溺尸斗士"
		13: return "腐化苦力怕"
		14: return "腐化蜘蛛"
		15: return "终末"
		16: return "丧尸野狼"
		17: return "腐化幻翼"
		18: return "腐朽"
		
		19: return "尸壳"
		20: return "尸壳勇士"
		21: return "沙漠狙击手"
		22: return "蠹虫"
		23: return "噩梦幻翼"
		24: return "沙漠守卫"
		25: return "木乃伊"
		26: return "黄金傀儡"
		27: return "沙漠雇佣兵"
		28: return "军火商"
		
		29 :return "厌国战士"
		30: return "厌国精英"
		31: return "苦力怕"
		32: return "厌国狂战士"
		33: return "劫掠者"
		34: return "卫道士"
		35: return "劫掠者队长"
		36: return "唤魔者"
		37: return "女巫"
		38: return "劫掠兽"
		39: return "史莱姆"
		40: return "幻翼"
		41: return "蜘蛛"
		42: return "恼鬼"
		43: return "泰坦威克斯"
		44: return "守卫者"
		
		_: return ""
	pass


#溺尸 = 11,
	#溺尸斗士 = 12,
	#腐化苦力怕 = 13,
	#腐化蜘蛛 = 14,
	#终末 = 15,
	#野狼 = 16,
	#丛林幻翼 = 17,
	#腐朽 = 18,
	#泰坦丧尸 = 55


func count():
	for i in max_wave_count:
		prints("第",i+1,"波")
		var wave_money_get: int
		for path_count in process_summon_blocks.size()/3:
			var group_summon_list: Dictionary
			print("第",path_count*3+1,path_count *3+2,path_count*3+3,"路")
			var process_path_1: PathSummonList = process_summon_blocks[path_count*3]
			var process_path_2: PathSummonList = process_summon_blocks[path_count*3+1]
			var process_path_3: PathSummonList = process_summon_blocks[path_count*3+2]
			for summon_block in process_path_1.wave_summon_list[i].summon_list:
				if !summon_block is WaitTimeBlock:
					if group_summon_list.has(enemy_id_to_string(summon_block.enemy_id)):
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] += summon_block.summon_count
					else:
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] = summon_block.summon_count
					
					wave_money_get += summon_block.summon_count * get_enemy_bounty(summon_block.enemy_id)
				
			for summon_block in process_path_2.wave_summon_list[i].summon_list:
				if !summon_block is WaitTimeBlock:
					if group_summon_list.has(enemy_id_to_string(summon_block.enemy_id)):
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] += summon_block.summon_count
					else:
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] = summon_block.summon_count
					
					wave_money_get += summon_block.summon_count * get_enemy_bounty(summon_block.enemy_id)
			
			for summon_block in process_path_3.wave_summon_list[i].summon_list:
				if !summon_block is WaitTimeBlock:
					if group_summon_list.has(enemy_id_to_string(summon_block.enemy_id)):
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] += summon_block.summon_count
					else:
						group_summon_list[enemy_id_to_string(summon_block.enemy_id)] = summon_block.summon_count
					wave_money_get += summon_block.summon_count * get_enemy_bounty(summon_block.enemy_id)
			
			print(group_summon_list)
		print("经济：", wave_money_get)
		print("")
	pass


func load_configs():
	for enemy_path: EnemyPath in enemy_parnt_node.get_children():
		process_summon_blocks.append(enemy_path.path_summon_config)
	pass


func get_enemy_bounty(enemy_id: int) -> int:
	match enemy_id:
		0: return 3
		1: return 6
		2: return 3
		3: return 2
		4: return 8
		5: return 35
		6: return 6
		7: return 60
		8: return 6
		9: return 8
		10: return 4
		11: return 6
		12: return 18
		13: return 8
		14: return 3
		15: return 60
		16: return 10
		17: return 6
		18: return 1
		
		19: return 4
		20: return 12
		21: return 8
		22: return 6
		23: return 8
		24: return 12
		25: return 10
		26: return 120
		27: return 12
		28: return 40
		
		29: return 15
		30: return 40
		31: return 25
		32: return 300
		33: return 18
		34: return 25
		35: return 50
		36: return 36
		37: return 40
		38: return 180
		39: return 80
		40: return 22
		41: return 12
		42: return 5
		43: return 80
		44: return 60
		
		_: return 0
	pass
