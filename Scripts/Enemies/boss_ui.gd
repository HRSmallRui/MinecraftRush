extends CanvasLayer
class_name BossUI

@export var linked_boss: Enemy

@onready var head_texture: TextureRect = $Panel/BossContainer/HeadTexture
@onready var name_label: Label = $Panel/NameLabel
@onready var health_bar: TextureProgressBar = $Panel/HealthBar
@onready var panel: Panel = $Panel


func _ready() -> void:
	health_bar.value = 0
	head_texture.texture = linked_boss.enemy_texture
	name_label.text = linked_boss.enemy_name
	pass


func _process(delta: float) -> void:
	var health_tween: Tween = create_tween().set_speed_scale(1 / Engine.time_scale)
	health_tween.tween_property(health_bar,"value",linked_boss.health_bar.value,abs(linked_boss.health_bar.value - health_bar.value)/(50 * delta))
	pass
