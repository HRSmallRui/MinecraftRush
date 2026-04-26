extends Node2D
class_name MoneyGetEffect

var money_count: int

@onready var money_label: Label = $MoneyLabel
@onready var gold: AudioStreamPlayer = $Gold


func _ready() -> void:
	gold.play(0.2)
	money_label.text = "+" + str(money_count)
	await $AnimationPlayer.animation_finished
	queue_free()
	pass
