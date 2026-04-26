extends Sprite2D

@export_group("WaveButton")
@export var center_wave_button: WaveButton
@export var left_wave_button: WaveButton
@export var right_wave_button: WaveButton
@export_group("WavePanelOutside")
@export var wave_panel_center: WavePanel
@export var wave_panel_left: WavePanel
@export var wave_panel_right: WavePanel

@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier
@onready var stop_control: ColorRect = $StopControl
@onready var house_front_mask_2: Sprite2D = $HouseFrontMask2
@onready var center_marker: Marker2D = $CenterMarker
@onready var left_marker: Marker2D = $LeftMarker
@onready var right_marker: Marker2D = $RightMarker
@onready var center_marker_inside: Marker2D = $CenterMarkerInside
@onready var left_marker_inside: Marker2D = $LeftMarkerInside
@onready var right_marker_inside: Marker2D = $RightMarkerInside
@onready var panel_center: Marker2D = $PanelCenter
@onready var panel_left: Marker2D = $PanelLeft
@onready var panel_right: Marker2D = $PanelRight
@onready var panel_center_inside: Marker2D = $PanelCenterInside
@onready var panel_left_inside: Marker2D = $PanelLeftInside
@onready var panel_right_inside: Marker2D = $PanelRightInside


var alpha_tween: Tween
var is_hidden: bool


func _process(delta: float) -> void:
	if is_hidden:
		if !visible_on_screen_notifier.is_on_screen() or Stage.instance.stage_camera.zoom.length() < 1:
			on_screen_out()
	elif visible_on_screen_notifier.is_on_screen() and Stage.instance.stage_camera.zoom.length() >= 1:
		on_screen_in()
	pass


func on_screen_in():
	if alpha_tween != null:
		alpha_tween.kill()
	alpha_tween = create_tween().set_parallel()
	alpha_tween.tween_property(self,"self_modulate:a",0,0.4)
	alpha_tween.tween_property(house_front_mask_2,"modulate:a",0,0.4)
	is_hidden = true
	stop_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	center_wave_button.position = center_marker_inside.global_position
	left_wave_button.position = left_marker_inside.global_position
	right_wave_button.position = right_marker_inside.global_position
	
	wave_panel_center.position = panel_center_inside.global_position
	wave_panel_left.position = panel_left_inside.global_position
	wave_panel_right.position = panel_right_inside.global_position
	pass


func on_screen_out():
	if alpha_tween != null:
		alpha_tween.kill()
	alpha_tween = create_tween().set_parallel()
	alpha_tween.tween_property(self,"self_modulate:a",1,0.4)
	alpha_tween.tween_property(house_front_mask_2,"modulate:a",1,0.4)
	is_hidden = false
	stop_control.mouse_filter = Control.MOUSE_FILTER_STOP
	if Stage.instance.stage_ui == Stage.StageUI.Check:
		Stage.instance.ui_process(null)
	
	center_wave_button.position = center_marker.global_position
	left_wave_button.position = left_marker.global_position
	right_wave_button.position = right_marker.global_position
	
	wave_panel_center.position = panel_center.global_position
	wave_panel_left.position = panel_left.global_position
	wave_panel_right.position = panel_right.global_position
	pass


func _on_stop_control_gui_input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		Stage.instance._on_click_area_input_event(null,event,0)
	pass # Replace with function body.
