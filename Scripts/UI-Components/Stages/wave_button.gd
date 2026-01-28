extends Control
class_name WaveButton

@export var linked_wave_panel: WavePanel
@export var wave_button_id: int = 0
@export var summon_text_list: Array[WaveSummonTextList]
@onready var texture_button: TextureButton = $TextureButton
@onready var mouse_over_audio: AudioStreamPlayer = $MouseOverAudio
@onready var wave_progress_bar: TextureProgressBar = $TextureButton/WaveProgressBar
@onready var back_button: TextureButton = $WaveOverScreenLayer/BackButton
@onready var wave_over_screen_layer: CanvasLayer = $WaveOverScreenLayer
@onready var screen_visible_node: VisibleOnScreenNotifier2D = $ScreenVisibleNode

var wave_animation_playing: bool = false


func _enter_tree() -> void:
	Stage.instance.wave_appear.connect(wave_show)
	Stage.instance.ui_update.connect(ui_process)
	Stage.instance.wave_summon.connect(on_wave_summon)
	hide()
	pass


func wave_show(wave_count: int):
	hide()
	wave_over_screen_layer.hide()
	if summon_text_list[wave_count-1] == null: return
	
	wave_over_screen_layer.show()
	var wave_text: String
	wave_text = get_summon_information(summon_text_list[wave_count-1].wave_summon_text_list)
	linked_wave_panel.update_wave_text(wave_text)
	show()
	wave_animation_playing = true
	modulate.a = 0
	texture_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var show_tween: Tween = create_tween()
	show_tween.tween_property(self,"modulate:a",1,0.4)
	await show_tween.finished
	wave_animation_playing = false
	texture_button.mouse_filter = Control.MOUSE_FILTER_STOP
	texture_button.disabled = false
	pass


func ui_process(memeber: Node):
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		texture_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
	else:
		texture_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	pass


func _on_texture_button_mouse_entered() -> void:
	mouse_over_audio.play()
	linked_wave_panel.show_panel()
	pass # Replace with function body.


func _on_texture_button_mouse_exited() -> void:
	linked_wave_panel.hide_panel()
	if MobileMiddleProcess.instance.current_touch_object == self:
		MobileMiddleProcess.instance.current_touch_object = null
	pass # Replace with function body.


func _on_texture_button_pressed() -> void:
	if OS.get_name() == "Android":
		if MobileMiddleProcess.instance.current_touch_object != self:
			MobileMiddleProcess.instance.current_touch_object = self
			return
	
	Stage.instance.wave_summon.emit(Stage.instance.current_wave + 1)
	pass # Replace with function body.


func on_wave_summon(wave_count: int):
	texture_button.disabled = true
	wave_over_screen_layer.hide()
	wave_animation_playing = true
	texture_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var show_tween: Tween = create_tween()
	show_tween.tween_property(self,"modulate:a",0,0.4)
	await show_tween.finished
	wave_animation_playing = false
	hide()
	pass


func _process(delta: float) -> void:
	control_back_button_visible()
	
	if Stage.instance.wave_during_timer.is_stopped():
		wave_progress_bar.value = 1
	else:
		var timer = Stage.instance.wave_during_timer as Timer
		wave_progress_bar.value = (timer.wait_time - timer.time_left) / timer.wait_time
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		texture_button.modulate.a = 1
		$Direction.modulate.a = 1
	else:
		texture_button.modulate.a = 0.4
		$Direction.modulate.a = 0.4
	pass


func get_summon_information(wave_summon_text_list: Array[SummonTextBlock]) -> String:
	var return_text: String
	for i in wave_summon_text_list.size():
		var text_block = wave_summon_text_list[i] as SummonTextBlock
		return_text += text_block.enemy_name + " x"
		if Stage.instance.stage_mode == Stage.StageMode.Bedrock:
			return_text += "?"
		else: return_text += str(text_block.enemy_count)
		if i < wave_summon_text_list.size() - 1:
			return_text += "\n"
	return return_text
	pass


func _on_back_button_pressed() -> void:
	Stage.instance.stage_camera.position = position
	back_button.hide()
	pass # Replace with function body.


func control_back_button_visible():
	if visible:
		var distance: Vector2 = position - Stage.instance.stage_camera.position
		back_button.visible = abs(distance.x) > (960+24) / Stage.instance.stage_camera.zoom.x or abs(distance.y) > (540+24) / Stage.instance.stage_camera.zoom.y
		var direction: Vector2 = (position - Stage.instance.stage_camera.position).normalized()
		var x_rate: float = abs(1920 / 2 / direction.x)
		var y_rate: float = abs(1080 / 2 / direction.y)
		back_button.position = Vector2(960,540)
		back_button.position += direction * x_rate if x_rate < y_rate else direction * y_rate
		back_button.position -= Vector2(24,24)
		back_button.position = Vector2(clampf(back_button.position.x,0,1872),clampf(back_button.position.y,0,1032))
	pass
