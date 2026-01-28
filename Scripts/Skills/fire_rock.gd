extends Area2D
class_name FirerainSkill

@onready var fire_rock_sprite: AnimatedSprite2D = $FireRockSprite
@onready var shadow: Sprite2D = $Shadow
@onready var destroy_timer: Timer = $DestroyTimer
@onready var water_condition_area: Area2D = $WaterConditionArea


var skill_level: int
var in_water: bool


func _ready() -> void:
	fire_rock_sprite.position = Vector2(-1920,-1080)
	shadow.position.x = -1920
	create_tween().tween_property(fire_rock_sprite,"position",Vector2.ZERO,0.8)
	create_tween().tween_property(shadow,"position:x",0,0.8)
	await destroy_timer.timeout
	attack_process()
	fire_land_process()
	hide()
	await get_tree().create_timer(0.2,false).timeout
	queue_free()
	pass


func attack_process():
	for hurt_box in get_overlapping_areas():
		var hurter = hurt_box.owner
		var damage: int
		match skill_level:
			0: damage = randi_range(40,60)
			1,2: damage = randi_range(50,80)
			3,4,5: damage = randi_range(60,120)
		if hurter is Enemy:
			hurter.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true,null,false)
	
	AudioManager.instance.play_explosion_audio()
	var explosion = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate() as AnimatedSprite2D
	var smoke = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate() as AnimatedSprite2D
	var fire_particle = preload("res://Scenes/Effects/fire_particle.tscn").instantiate() as AnimatedSprite2D
	explosion.position = position
	smoke.position = position
	fire_particle.position = position
	Stage.instance.bullets.add_child(explosion)
	Stage.instance.bullets.add_child(smoke)
	Stage.instance.bullets.add_child(fire_particle)
	
	if water_condition_area.has_overlapping_areas():
		AudioManager.instance.play_water_audio()
		var water_effect: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		water_effect.position = position + Vector2(0,20)
		water_effect.scale *= 1.5
		water_effect.modulate = Color(0,0.8,1,0.6)
		Stage.instance.bullets.add_child(water_effect)
		in_water = true
	pass


func fire_land_process():
	if skill_level < 2: return
	var fire_land: FireHurtArea = preload("res://Scenes/Skills/fire_hurt_area.tscn").instantiate()
	fire_land.position = position
	fire_land.in_water = in_water
	match skill_level:
		2,3: fire_land.skill_level = 1
		4,5: fire_land.skill_level = 2
	Stage.instance.bullets.add_child(fire_land)
	pass
