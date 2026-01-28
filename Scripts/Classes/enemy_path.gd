##用作Enemy类的父节点，敌人的行进路线
extends Path2D
class_name EnemyPath

static var enemy_registor_path_list: Dictionary = { ##注册的敌人场景列表
	0: "res://Scenes/Enemies/enemy_0.tscn", ##尸国杂兵
	1: "res://Scenes/Enemies/enemy_1.tscn", ##尸国皮甲兵
	2: "res://Scenes/Enemies/enemy_2.tscn", ##尸国小鬼
	3: "res://Scenes/Enemies/enemy_3.tscn", ##鸡骑士
	4: "res://Scenes/Enemies/enemy_4.tscn", ##尸国正规军
	5: "res://Scenes/Enemies/enemy_5.tscn", ##尸国壮汉
	6: "res://Scenes/Enemies/enemy_6.tscn", ##尸国刺杀者
	7: "res://Scenes/Enemies/enemy_7.tscn", ##尸国贵族战士
	8: "res://Scenes/Enemies/enemy_8.tscn", ##骨国步兵
	9: "res://Scenes/Enemies/enemy_9.tscn", ##骨国正规军
	54: "res://Scenes/Enemies/enemy_54.tscn", ##尸国统帅
	
	10: "res://Scenes/Enemies/enemy_10.tscn", ##野区丧尸
	11: "res://Scenes/Enemies/enemy_11.tscn", ##溺尸
	12: "res://Scenes/Enemies/enemy_12.tscn", ##溺尸斗士
	13: "res://Scenes/Enemies/enemy_13.tscn", ##腐化爬行者,
	14: "res://Scenes/Enemies/enemy_14.tscn", ##腐化蜘蛛
	15: "res://Scenes/Enemies/enemy_15.tscn", ##终末
	16: "res://Scenes/Enemies/enemy_16.tscn", ##丧尸野狼
	17: "res://Scenes/Enemies/enemy_17.tscn", ##丛林幻翼
	18: "res://Scenes/Enemies/enemy_18.tscn", ##腐朽
	55: "res://Scenes/Enemies/enemy_55.tscn", ##泰坦丧尸
	
	19: "res://Scenes/Enemies/enemy_19.tscn", ##尸壳
	20: "res://Scenes/Enemies/enemy_20.tscn", ##尸壳勇士
	21: "res://Scenes/Enemies/enemy_21.tscn", ##沙漠狙击手
	22: "res://Scenes/Enemies/enemy_22.tscn", ##蠹虫
	23: "res://Scenes/Enemies/enemy_23.tscn", ##噩梦幻翼
	24: "res://Scenes/Enemies/enemy_24.tscn", ##沙漠守卫
	25: "res://Scenes/Enemies/enemy_25.tscn", ##木乃伊
	26: "res://Scenes/Enemies/enemy_26.tscn", ##黄金傀儡
	27: "res://Scenes/Enemies/enemy_27.tscn", ##沙漠雇佣兵
	28: "res://Scenes/Enemies/enemy_28.tscn", ##军火商
	56: "res://Scenes/Enemies/enemy_56.tscn", ##巨型尸壳
	
	29: "res://Scenes/Enemies/enemy_29.tscn", ##厌国战士
	30: "res://Scenes/Enemies/enemy_30.tscn", ##厌国精英
	31: "res://Scenes/Enemies/enemy_31.tscn", ##苦力怕
	32: "res://Scenes/Enemies/enemy_32.tscn", ##厌国狂战士
	33: "res://Scenes/Enemies/enemy_33.tscn", ##劫掠者
	34: "res://Scenes/Enemies/enemy_34.tscn", ##卫道士
	35: "res://Scenes/Enemies/enemy_35.tscn", ##劫掠队长
	36: "res://Scenes/Enemies/enemy_36.tscn", ##唤魔者
	37: "res://Scenes/Enemies/enemy_37.tscn", ##女巫
	38: "res://Scenes/Enemies/enemy_38.tscn", ##劫掠兽
	39: "res://Scenes/Enemies/enemy_39.tscn", ##史莱姆
	40: "res://Scenes/Enemies/enemy_40.tscn", ##幻翼
	41: "res://Scenes/Enemies/enemy_41.tscn", ##蜘蛛
	42: "res://Scenes/Enemies/enemy_42.tscn", ##恼鬼
	43: "res://Scenes/Enemies/enemy_43.tscn", ##泰坦威克斯
	44: "res://Scenes/Enemies/enemy_44.tscn", ##守卫者
	57: "res://Scenes/Enemies/enemy_57.tscn", ##远古守卫者
}

@export var path_id: int
@export var enabled: bool = true
@export var path_summon_config: PathSummonList
@export var boss_wave_config: BossWaveConfig

var summon_list: Array
var summoning_finished: bool = false


func _enter_tree() -> void:
	
	pass


func _ready() -> void:
	Stage.instance.wave_summon.connect(wave_summon)
	pass


func wave_summon(wave_count: int):
	var wave_summon_list: SummonWaveBlock = path_summon_config.wave_summon_list[wave_count-1]
	for summon_block: SummonBlock in wave_summon_list.summon_list:
		if summon_block is WaitTimeBlock:
			await wait_timer(summon_block.wait_time).timeout
		else:
			for i in summon_block.summon_count:
				var enemy_scene = load(enemy_registor_path_list[summon_block.enemy_id]) as PackedScene
				var enemy = enemy_scene.instantiate() as Enemy
				add_child(enemy)
				on_enemy_summoning(enemy)
				if i < summon_block.summon_count-1:
					await wait_timer(summon_block.time_interval).timeout
	
	if Stage.instance.current_wave >= Stage.instance.total_waves: summoning_finished = true
	pass


func wait_timer(wait_time: float) -> OneShotTimer:
	var timer: OneShotTimer = OneShotTimer.new()
	timer.wait_time = wait_time
	timer.autostart = true
	add_child(timer)
	return timer
	pass


func on_enemy_summoning(enemy: Enemy):
	
	pass


func boss_wave_summon():
	
	pass
