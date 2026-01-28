extends Node2D
class_name LevelFlag

signal show_finished
signal flag_access_animation_finished

@export var last_level: int

@onready var diamond_sprite: Sprite2D = $DiamondSprite
@onready var flag_sprite: AnimatedSprite2D = $FlagSprite
@onready var star_1: Sprite2D = $Star1
@onready var star_2: Sprite2D = $Star2
@onready var star_3: Sprite2D = $Star3
@onready var levelup_audio: AudioStreamPlayer = $LevelupAudio
@onready var star_audio: AudioStreamPlayer = $StarAudio
@onready var flag_audio: AudioStreamPlayer = $FlagAudio

@export var flag_level: int


func _ready() -> void:
	
	start()
	pass


func _on_button_pressed() -> void:
	Map.instance.open_fight_ui(flag_level)
	Map.instance.camera.position = self.position
	pass # Replace with function body.


func _on_button_mouse_entered() -> void:
	if OS.get_name() == "Android":
		return
	
	if flag_sprite.animation == "battle_flow":
		flag_sprite.play("battle_select")
	elif flag_sprite.animation == "defence_flow":
		flag_sprite.play("defence_select")
	elif flag_sprite.animation == "bedrock_flow":
		flag_sprite.play("bedrock_select")
	pass # Replace with function body.


func _on_button_mouse_exited() -> void:
	if OS.get_name() == "Android":
		return
	
	if flag_sprite.animation == "battle_select":
		flag_sprite.play("battle_flow")
	elif flag_sprite.animation == "defence_select":
		flag_sprite.play("defence_flow")
	elif flag_sprite.animation == "bedrock_select":
		flag_sprite.play("bedrock_flow")
	pass # Replace with function body.


func start():
	if !Map.instance.current_sav.level_sav.has(flag_level):
		hide()
		if Map.instance.current_sav.level_sav.has(last_level):
			if Map.instance.current_sav.level_sav[last_level][1] > 0: 
				Map.instance.current_sav.level_sav[flag_level] = [false,0,0,0]
				Global.sav_game_sav(Map.instance.current_sav)
		return
	else:
		visible = Map.instance.current_sav.level_sav[flag_level][0]
	
	if Map.animation_stage_count == flag_level:
		star_1.visible = Map.level_animation_type > Map.LevelAnimationType.Campaign0_3
		star_2.visible = Map.level_animation_type > Map.LevelAnimationType.Campaign1_3
		star_3.visible = Map.level_animation_type > Map.LevelAnimationType.Campaign2_3
		diamond_sprite.visible = Map.level_animation_type == Map.LevelAnimationType.Diamond_Bedrock
		if Map.level_animation_type < Map.LevelAnimationType.Campaign1_2:
			flag_sprite.play("battle_flow")
		elif Map.level_animation_type < Map.LevelAnimationType.Bedrock_Diamond:
			flag_sprite.play("defence_flow")
		elif Map.level_animation_type == Map.LevelAnimationType.Bedrock_Diamond:
			flag_sprite.play("bedrock_flow")
	else:
		var level_sav_block: Array = Map.instance.current_sav.level_sav[flag_level]
		star_1.visible = level_sav_block[1] > 0
		star_2.visible = level_sav_block[1] > 1
		star_3.visible = level_sav_block[1] > 2
		if level_sav_block[1] == 0:
			flag_sprite.play("battle_flow")
		elif level_sav_block[3] > 0:
			flag_sprite.play("bedrock_flow")
		else: flag_sprite.play("defence_flow")
		diamond_sprite.visible = level_sav_block[2] > 0
	pass


func show_from_hidden():
	if !Map.instance.current_sav.level_sav.has(flag_level):
		await get_tree().create_timer(0.01).timeout
		show_finished.emit()
		return
	if !Map.instance.current_sav.level_sav[flag_level][0]:
		Map.instance.current_sav.level_sav[flag_level][0] = true
		show()
		$Button.hide()
		flag_sprite.play("battle_show")
		flag_sprite.offset.y = -100
		await flag_sprite.animation_finished
		flag_audio.play()
		flag_sprite.play("battle_flow")
		flag_sprite.offset.y = 0
		$Button.show()
		Global.sav_game_sav(Map.instance.current_sav)
		await get_tree().create_timer(0.5).timeout
		show_finished.emit()
	else:
		await get_tree().create_timer(0.01).timeout
		show_finished.emit()
	pass


func flag_reward_animation():
	if Map.level_animation_type < Map.LevelAnimationType.Campaign1_2:
		await get_tree().create_timer(0.2).timeout
		flag_sprite.play("defence_flow")
		levelup_audio.play(0.2)
	elif Map.level_animation_type == Map.LevelAnimationType.Campaign_Diamond or Map.level_animation_type == Map.LevelAnimationType.Bedrock_Diamond:
		await get_tree().create_timer(0.2).timeout
		diamond_sprite.show()
		levelup_audio.play(0.2)
	elif Map.level_animation_type == Map.LevelAnimationType.Campaign_Bedrock or Map.level_animation_type == Map.LevelAnimationType.Diamond_Bedrock:
		await get_tree().create_timer(0.2).timeout
		flag_sprite.play("bedrock_flow")
		levelup_audio.play(0.2)
	Map.instance.camera.position = position
	
	await get_tree().create_timer(1).timeout
	var level_sav_block: Array = Map.instance.current_sav.level_sav[flag_level]
	if !star_1.visible and level_sav_block[1] > 0:
		star_1.show()
		star_audio.play()
		await get_tree().create_timer(0.4).timeout
	if !star_2.visible and level_sav_block[1] >= 2:
		star_2.show()
		star_audio.play()
		await get_tree().create_timer(0.4).timeout
	if !star_3.visible and level_sav_block[1] >= 3:
		star_3.show()
		star_audio.play()
		await get_tree().create_timer(0.4).timeout
	
	Map.animation_stage_count = 0
	flag_access_animation_finished.emit()
	pass
