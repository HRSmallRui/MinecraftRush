extends CanvasLayer
class_name StoryLayer

@export var ending_time: float
@export var dialog_list: Array[DialogBlock]
@export var cg_list: Array[CGTextureBlock]
@export var subtitle: Label
@export var skip_button: Button
@export var cg_player: Sprite2D

func _ready() -> void:
	show()
	subtitle.text = ""
	skip_button.pressed.connect(func():
		get_tree().paused = false
		queue_free())
	get_tree().paused = process_mode == ProcessMode.PROCESS_MODE_ALWAYS
	for dialog_block in dialog_list:
		subtitle_change(dialog_block.dialog_text,dialog_block.text_exist_time,dialog_block.text_color)
	for cg_block in cg_list:
		cg_play(cg_block.cg_texture,cg_block.cg_appear_time,cg_block.cg_during_time)
	
	await get_tree().create_timer(ending_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	disappear()
	pass


func subtitle_change(new_word: String, appear_time: float, text_color: Color):
	await get_tree().create_timer(appear_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	subtitle.modulate = text_color
	var word_tween: Tween = create_tween()
	subtitle.text = new_word
	subtitle.visible_characters = 0
	word_tween.tween_property(subtitle,"visible_characters",new_word.length(),float(new_word.length()) / 30)
	#word_tween.tween_callback(func():
		#await get_tree().create_timer(during_time).timeout
		#subtitle.visible_characters = 0)
	pass


func disappear():
	var disappear_time: float = 0.5
	create_tween().tween_property(subtitle,"modulate:a",0,disappear_time)
	
	await get_tree().create_timer(disappear_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	queue_free()
	get_tree().paused = false
	pass


func cg_play(cg_texture: Texture, cg_appear_time: float, cg_during_time: float):
	await get_tree().create_timer(cg_appear_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	cg_player.modulate.a = 0
	cg_player.texture = cg_texture
	create_tween().tween_property(cg_player,"modulate:a",1,0.5)
	await get_tree().create_timer(cg_during_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	create_tween().tween_property(cg_player,"modulate:a",0,0.5)
	pass
