extends SkillConditionArea2D

@export var lightning_random_texture_list: Array[Texture]

@onready var lightning_sprite: Sprite2D = $LightningSprite
@onready var timer: Timer = $Timer


func _ready() -> void:
	lightning_sprite.texture = lightning_random_texture_list[randi_range(0,lightning_random_texture_list.size()-1)]
	disappear()
	var operation_data: float = HeroSkillLibrary.hero_skill_data_library[4][4].upgrade_rate[skill_level-1]
	await get_tree().physics_frame
	await get_tree().physics_frame
	for hurtbox in get_overlapping_areas():
		var ally: Ally = hurtbox.owner
		if ally is Hero: continue
		var strength_buff: PropertyBuff = preload("res://Scenes/Buffs/Robort/robort_lightning_strength.tscn").instantiate()
		for buff_block in strength_buff.buff_blocks:
			buff_block.operation_data = operation_data
		ally.buffs.add_child(strength_buff)
	pass


func _on_timer_timeout() -> void:
	var erase_texture: Texture = lightning_sprite.texture
	var random_list: Array[Texture] = lightning_random_texture_list.duplicate()
	random_list.erase(erase_texture)
	lightning_sprite.texture = random_list[randi_range(0,random_list.size()-1)]
	pass # Replace with function body.


func disappear():
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(lightning_sprite,"modulate:a",0,0.5)
	create_tween().tween_property(lightning_sprite,"scale",lightning_sprite.scale * 2, 0.5)
	await disappear_tween.finished
	queue_free()
	pass
