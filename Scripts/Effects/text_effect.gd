extends Node2D
class_name TextEffect

enum TextEffectType{
	Arrow,
	Barrack,
	Magic,
	Bombard,
	SecKill
}

@export var show_text: String
@export var text_effect_type: TextEffectType
@export var text_effect_color_list: Array[Color]
@export var text_effect_under_color_list: Array[Color]

@onready var under_label: Label = $UnderLabel
@onready var text_label: Label = $TextLabel


func _ready() -> void:
	var tween_scale: Vector2 = scale
	under_label.modulate = text_effect_under_color_list[text_effect_type]
	text_label.modulate = text_effect_color_list[text_effect_type]
	text_label.text = show_text
	under_label.text = show_text
	rotation_degrees = randf_range(-15,15)
	var effect_tween: Tween = create_tween()
	scale = Vector2.ZERO
	effect_tween.tween_property(self,"scale",tween_scale,0.1)
	await get_tree().create_timer(0.7,false).timeout
	create_tween().tween_property(self,"modulate:a",0,0.4)
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass


static func text_effect_show(text: String,show_type: TextEffectType,show_pos: Vector2):
	var text_effect = preload("res://Scenes/Effects/text_effect.tscn").instantiate() as TextEffect
	text_effect.show_text = text
	text_effect.text_effect_type = show_type
	text_effect.position = show_pos
	Stage.instance.add_child(text_effect)
	pass
