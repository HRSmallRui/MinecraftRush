extends CanvasLayer

@onready var lose_label: Label = $Button/Panel/LoseLabel

@export_multiline var lost_word_list: Array[String] = [
	"菜就多练。",
	"提前召唤一波敌人不能减少防御塔技能的冷却时间。",
	"提前召唤下一波敌人可以获得额外绿宝石奖励并减少技能冷却。",
	"血量剩余18以上才可以获得三星评价。",
	"血量剩余5以上可以获得二星评价。",
	"对付顽强的敌人，秒杀是个很好的效果。",
	"不行开个修改器吧？"
]


func _ready() -> void:
	get_tree().paused = true
	lose_label.text = lost_word_list[randi_range(0,lost_word_list.size()-1)]
	pass


func _on_finish_button_pressed() -> void:
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass # Replace with function body.


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and !$AnimationPlayer.is_playing():
		_on_finish_button_pressed()
	pass
