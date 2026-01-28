extends CanvasLayer

@onready var subtitle: Label = $Subtitle
var later_scene = preload("res://Scenes/Stages/Stage1/stage_1_campaign_later.tscn")
@onready var skip_button: Button = $SkipButton


func subtitle_change(new_word: String, appear_time: float, during_time: float):
	await get_tree().create_timer(appear_time,false).timeout
	subtitle.modulate.a= 0
	var word_tween: Tween = create_tween()
	subtitle.text = new_word
	word_tween.tween_property(subtitle,"modulate:a",1,0.4)
	word_tween.tween_callback(func():
		await get_tree().create_timer(during_time,false).timeout
		create_tween().tween_property(subtitle,"modulate:a",0,0.4))
	pass


func _ready() -> void:
	subtitle.text = ""
	subtitle_change("焦土终会复生，但伤疤永不弥合",1,4)
	subtitle_change("世间万物没有什么是永恒的",8,3)
	subtitle_change("自然那些伟大的传说",16,3)
	subtitle_change("无法描述的过去",21,3)
	subtitle_change("终会在某一天烟消云散",26,4)
	subtitle_change("我们用两代人的光阴编制了谎言",36,4)
	subtitle_change("说和平已然被砌进了宏伟的城墙中",42,5)
	subtitle_change("安宁将随着钟摆永恒往复",50,4)
	subtitle_change("但直到有一天",60,4)
	subtitle_change("它还是被打破了",68,4)
	subtitle_change("或者说",76,3)
	subtitle_change("终于被打破了",82,3)
	subtitle_change("我们看到他们卷土重来，势如破竹",88,4)
	
	subtitle_change("或许真正的和平永远不会到来，战争永远都在",94,6)
	subtitle_change("但",102,2)
	subtitle_change("请听那炮火连绵的喧嚣",106,3)
	subtitle_change("请看那狼烟四起的边境",110,3)
	subtitle_change("我们需要你，守卫者……",118,4)
	subtitle_change("我们需要你比任何史官都更早写下这场战争的终章……",124,4)
	
	await get_tree().create_timer(132,false).timeout
	get_tree().change_scene_to_packed(later_scene)
	pass


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("click") or event.is_action_pressed("escape"):
		#get_tree().paused = true
		#await get_tree().create_timer(0.3,true).timeout
		#get_tree().paused = false
		#get_tree().change_scene_to_packed(later_scene)
	#pass


func _on_skip_button_pressed() -> void:
	get_tree().paused = true
	await get_tree().create_timer(0.3,true).timeout
	get_tree().paused = false
	get_tree().change_scene_to_packed(later_scene)
	pass # Replace with function body.
