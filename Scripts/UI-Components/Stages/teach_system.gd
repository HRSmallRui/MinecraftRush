extends CanvasLayer
class_name TeachSystem

@onready var intro_label: Label = $IntroLabel
@onready var enemy_point_1: PointLight2D = $ShowComponent/EnemyPoint1
@onready var directional_light: DirectionalLight2D = $DirectionalLight
@onready var all_stop: ColorRect = $AllStop
@onready var wave_click_component: Control = $WaveClickComponent
@onready var tower_point: PointLight2D = $TowerPoint


func _ready() -> void:
	if Stage.instance.stage_sav.level_sav[1][1] > 0:
		queue_free()
		return
	await get_tree().process_frame
	Stage.instance.can_control = false
	get_tree().paused = true
	Stage.instance.zoom_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Stage.instance.update_player_status()
	directional_light.energy = 0
	intro_label.text = ""
	opening()
	await get_tree().create_timer(28).timeout
	step1()
	await get_tree().create_timer(6.5).timeout
	step2()
	pass


func opening():
	change_intro_text("欢迎归来，将军",0)
	change_intro_text("我知道这个时间把你召回有些不合时宜，但我们需要“守护”的力量",3)
	change_intro_text("我不知道离开战场那么久你是否还记得怎么建立防线与指挥战斗",8)
	change_intro_text("有一小支分队绕过了防线正在朝这边移动",13)
	change_intro_text("很高兴你回来的时候记得临时拼凑一支队伍，那么皇城这边暂且交由你负责",16)
	change_intro_text("我们需要抓紧时间建立防线",24)
	pass


func change_intro_text(new_text: String,delay_time: float):
	await get_tree().create_timer(delay_time,true).timeout
	intro_label.visible_characters = 0
	intro_label.text = new_text
	var time:float = float(new_text.length())/20
	create_tween().tween_property(intro_label,"visible_characters",new_text.length(),time)
	pass


func step1():
	get_tree().paused = false
	change_intro_text("",0)
	change_intro_text("敌人会从这里出现",0.5)
	Stage.instance.stage_camera.position = Vector2(1920,0)
	Stage.instance.stage_camera.position_clamp()
	enemy_point_animation($ShowComponent/EnemyPoint1,2.8)
	enemy_point_animation($ShowComponent/EnemyPoint2,2.8)
	change_intro_text("不要让他们突破据点",3)
	Stage.instance.stage_camera.position = $ShowComponent/HomePoint.position
	Stage.instance.stage_camera.position_clamp()
	home_point_animation()
	change_intro_text("",6)
	pass


func enemy_point_animation(enemy_point: PointLight2D,during_time: float):
	enemy_point.show()
	enemy_point.energy = 0
	enemy_point.scale = Vector2.ONE * 2
	create_tween().tween_property(directional_light,"energy",0.4,0.4)
	var show_enemy_tween: Tween = create_tween().set_parallel()
	show_enemy_tween.tween_property(enemy_point,"energy",0.8,0.5)
	show_enemy_tween.tween_property(enemy_point,"scale",Vector2.ONE,0.7)
	await get_tree().create_timer(during_time).timeout
	enemy_point.hide()
	pass


func home_point_animation():
	var home_point: PointLight2D = $ShowComponent/HomePoint
	await get_tree().create_timer(3).timeout
	home_point.show()
	home_point.scale = Vector2.ONE * 2
	home_point.energy = 0
	create_tween().tween_property(home_point,"energy",0.8,0.5)
	create_tween().tween_property(home_point,"scale",Vector2.ONE,0.7)
	await get_tree().create_timer(3).timeout
	create_tween().tween_property(home_point,"energy",0,0.4)
	pass


func step2():
	enemy_point_animation($ShowComponent/EnemyPoint1,0.5)
	Stage.instance.stage_camera.position = $ShowComponent/EnemyPoint1.position
	Stage.instance.stage_camera.position_clamp()
	change_intro_text("单击此处，准备迎接敌人的进攻",0)
	await get_tree().create_timer(0.501).timeout
	all_stop.hide()
	wave_click_component.show()
	$ShowComponent/EnemyPoint1.show()
	await Stage.instance.wave_summon
	create_tween().tween_property(enemy_point_1,"energy",0,0.4)
	create_tween().tween_property(directional_light,"energy",0,0.4)
	change_intro_text("",1)
	await get_tree().create_timer(2).timeout
	step3()
	pass


func step3():
	all_stop.show()
	change_intro_text("很好，他们来了！",0.5)
	get_tree().paused = true
	enemy_point_animation(enemy_point_1,0.1)
	await get_tree().create_timer(0.11).timeout
	enemy_point_1.show()
	
	var based_tower = Stage.instance.towers.get_child(3) as DefenceTower
	change_intro_text("建造防御塔来抵御他们的攻势",2)
	Stage.instance.stage_camera.position = Vector2(1920/2, 1080/2)
	Stage.instance.stage_camera.position_clamp()
	tower_point.energy = 0
	tower_point.show()
	await get_tree().create_timer(2).timeout
	create_tween().tween_property(tower_point,"energy",0.8,0.4)
	create_tween().tween_property(enemy_point_1,"energy",0,0.4)
	await get_tree().create_timer(0.6).timeout
	based_tower.process_mode = Node.PROCESS_MODE_ALWAYS
	based_tower._on_tower_button_pressed()
	create_tween().tween_property(tower_point,"scale",Vector2.ONE * 2,0.4)
	await get_tree().create_timer(1).timeout
	based_tower.tower_panel_ui.show_panel(0,1)
	await get_tree().create_timer(1).timeout
	first_building(based_tower)
	pass


func first_building(tower: DefenceTower):
	change_intro_text("",0.1)
	tower.tower_level_up(DefenceTower.TowerType.Archer,1)
	Stage.instance.current_money -= 70
	get_tree().paused = false
	create_tween().tween_property(tower_point,"energy",0,0.4)
	create_tween().tween_property(directional_light,"energy",0,0.4)
	var enemy = Stage.instance.enemies.get_child(0).get_child(0) as Enemy
	await enemy.current_data.die
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = true
	$EnemyPoint3.show()
	$EnemyPoint3.position = enemy.position
	enemy_point_animation($EnemyPoint3,4)
	step4()
	pass


func step4():
	change_intro_text("消灭敌人可以获得绿宝石，这是建造与升级防御塔的必要资源",1)
	change_intro_text("共有四种防御塔可供使用",4)
	await get_tree().create_timer(4).timeout
	$TowerIntro/AnimationPlayer.play("unfold")
	$TowerIntro.show()
	await $TowerIntro/AnimationPlayer.animation_finished
	$TowerIntro/AnimationPlayer.play("name_appear")
	await $TowerIntro/AnimationPlayer.animation_finished
	$TowerIntro/AnimationPlayer.play("intro_appear")
	await $TowerIntro/AnimationPlayer.animation_finished
	change_intro_text("不同防御塔有各自不同的特点以及适应场合",0.5)
	change_intro_text("这些防御塔也有各自善于应对的场合与难以应付的敌人",2)
	change_intro_text("根据不同场合选择对应的防御塔来应对，合理搭配不同防御塔的使用，能够做到优势互补",5)
	change_intro_text("这样能够做到在任何敌人面前都能保留优势区间",9)
	change_intro_text("左上角分别为生命值，当前所剩绿宝石与敌人波次",12)
	change_intro_text("如果防线被突破，会依据敌人的“代价”扣除相应生命值，减到0时当前关卡失败",15)
	change_intro_text("战役结束后会根据所剩生命给予评价，评价给予的下界之星可以在外部升级后勤来应对日后强大的敌人",20)
	change_intro_text("某些情况下，波次信息可能会受到干扰，这种情况下请谨慎对待",26)
	change_intro_text("右上角为暂停按钮，可以帮助你争取一些思考战局的时间",30)
	change_intro_text("部分情况可能会被破坏",34)
	change_intro_text("继续战斗吧！",34.6)
	await get_tree().create_timer(38).timeout
	change_intro_text("",0.1)
	Stage.instance.zoom_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	all_stop.hide()
	create_tween().tween_property(directional_light,"energy",0,0.4)
	create_tween().tween_property($TowerIntro,"modulate:a",0,0.4)
	wave_click_component.hide()
	get_tree().paused = false
	Stage.instance.can_control = true
	await Stage.instance.wave_summon
	reinforce_tutorial()
	await Stage.instance.wave_summon
	await Stage.instance.wave_summon
	hero_tutorial()
	await Stage.instance.wave_summon
	heroskill_tutorial()
	await Stage.instance.wave_summon
	firerain_tutorial()
	pass


func reinforce_tutorial():
	await get_tree().create_timer(2,false).timeout
	Stage.instance.add_child(preload("res://Scenes/TipUI/reinforce_unlock.tscn").instantiate())
	await get_tree().create_timer(0.3,false).timeout
	var reinforce_skill_button: SkillButton = Stage.instance.skill_button_container.get_child(1)
	reinforce_skill_button.unlock()
	pass


func hero_tutorial():
	await get_tree().create_timer(2,false).timeout
	Stage.instance.add_child(preload("res://Scenes/TipUI/hero_unlock.tscn").instantiate())
	await get_tree().create_timer(0.3,false).timeout
	Stage.instance.summon_hero(Stage.instance.hero_summon_marker.position - Vector2(300,0))
	await get_tree().create_timer(0.5,false).timeout
	var hero = Stage.instance.hero_list[0] as Hero
	hero.station_position = Stage.instance.hero_summon_marker.global_position
	hero.move_back()
	pass


func heroskill_tutorial():
	await get_tree().create_timer(2,false).timeout
	Stage.instance.add_child(preload("res://Scenes/TipUI/heroskill_unlock.tscn").instantiate())
	await get_tree().create_timer(0.3,false).timeout
	var skill_button: SkillButton = Stage.instance.skill_button_container.get_child(2)
	skill_button.unlock()
	pass


func firerain_tutorial():
	await get_tree().create_timer(2,false).timeout
	Stage.instance.add_child(preload("res://Scenes/TipUI/firerain_unlock.tscn").instantiate())
	await get_tree().create_timer(0.3,false).timeout
	var skill_button: SkillButton = Stage.instance.skill_button_container.get_child(0)
	skill_button.unlock()
	pass


func _on_skip_button_pressed() -> void:
	get_tree().paused = false
	Stage.instance.add_child(preload("res://Scenes/UI-Components/Stages/tutorial_warning.tscn").instantiate())
	Stage.instance.summon_hero()
	
	queue_free()
	pass # Replace with function body.
