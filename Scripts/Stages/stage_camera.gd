extends Camera2D
class_name StageCamera

@export var move_limit_shape: CollisionShape2D
@export_group("desktop")
@export var max_zoom_length_desktop: float = 2
@export var min_zoom_length_desktop: float = 1
@export_group("mobile")
@export var max_zoom_length_mobile: float = 2
@export var min_zoom_length_mobile: float = 1.35

@onready var drag_label: Label = $"../StageUI/DragLabel"

var left_top_position: Vector2
var right_down_position: Vector2
var offset_strength: float
var touch_count: int = 0
var touch_list: Array[InputEventScreenDrag] = [null,null]

var min_zoom: float
var max_zoom: float
var draging_list: Dictionary


func _ready() -> void:
	update_move_limit()
	min_zoom = min_zoom_length_mobile if OS.get_name() == "Android" else min_zoom_length_desktop
	max_zoom = max_zoom_length_mobile if OS.get_name() == "Android" else max_zoom_length_desktop
	zoom_clamp()
	position_clamp()
	pass


func _input(event: InputEvent) -> void:
	if !Stage.instance.can_control: return
	#var direction: Vector2 = (Stage.instance.get_local_mouse_position() - position) * 0.1
	if OS.get_name() == "Windows":
		windows_control(event)
	elif OS.get_name() == "Android":
		phone_control(event)
	
	zoom_clamp()
	position_clamp()
	pass


#func _unhandled_input(event: InputEvent) -> void:
	#if !OS.get_name() == "Android": return
	#if !Stage.instance.can_control: return
	#if event is InputEventScreenDrag:
		#if event.index <= 1: touch_list[event.index] = event
		#
		#elif event.index == 1:
			#var center_position:Vector2 = (touch_list[0].position + touch_list[1].position)/2
			#var first_delta:float = (touch_list[0].position + touch_list[0].relative - center_position).length() - (touch_list[0].position - center_position).length()
			#var second_delta: float = (touch_list[1].position + touch_list[1].relative - center_position).length() - (touch_list[1].position - center_position).length()
			#var delta_zoom: float = first_delta + second_delta
			#zoom += Vector2.ONE * delta_zoom * 0.01
			#zoom = clamp(zoom,Vector2(1,1),Vector2(2.5,2.5))
	#pass

func windows_control(event: InputEvent):
	if event is InputEventScreenDrag:
		position -= event.relative * 0.8
	elif event.is_action_pressed("scroll_up"):
		zoom += Vector2(0.05,0.05)
		#position += direction
	elif event.is_action_pressed("scroll_down"):
		zoom -= Vector2(0.05,0.05)
		#position -= direction
	pass


func phone_control(event: InputEvent):
	if event is InputEventScreenDrag:
		var i = event.index
		draging_list[i] = event
		if draging_list.size() == 1 and i == 0:
			position -= event.relative * 0.8
		elif draging_list.size() == 2 and i >= 1:
			var event_1: InputEventScreenDrag = draging_list[draging_list.keys()[0]]
			var event_2: InputEventScreenDrag = draging_list[draging_list.keys()[1]]
			var current_frame_length: float = (event_1.position - event_2.position).length()
			var last_frame_length: float = ((event_1.position - event_1.relative) - (event_2.position - event_2.relative)).length()
			var delta_length: float = current_frame_length - last_frame_length
			zoom += Vector2(0.05,0.05) * delta_length / 50
	if event is InputEventScreenTouch:
		if !event.pressed:
			var i = event.index
			draging_list.erase(i)
	
	drag_label.text = str(draging_list)
	pass


func _process(delta: float) -> void:
	position_clamp()
	position += Input.get_vector("camera_left","camera_right","camera_up","camera_down") * 10
	offset = Vector2(randf_range(-offset_strength,offset_strength),randf_range(-offset_strength,offset_strength))
	
	if offset_strength < 1:
		offset_strength = 0
	else:
		offset_strength -= 20 * delta
	if offset_strength < 0: offset_strength = 0
	pass


func zoom_clamp():
	
	zoom.x = clampf(zoom.x,min_zoom,max_zoom)
	zoom.y = zoom.x
	pass


func update_move_limit():
	left_top_position = move_limit_shape.shape.get_rect().position + move_limit_shape.position
	right_down_position = move_limit_shape.shape.get_rect().end + move_limit_shape.position
	pass


func position_clamp():
	position.x = clampf(position.x,left_top_position.x + 960 / zoom.x, right_down_position.x - 960 / zoom.x)
	position.y = clampf(position.y,left_top_position.y + 540 / zoom.y, right_down_position.y - 540 / zoom.y)
	limit_left = left_top_position.x
	limit_top = left_top_position.y
	limit_bottom = right_down_position.y
	limit_right = right_down_position.x
	pass


func shake(shake_strength: float):
	offset_strength = shake_strength
	pass


func _on_zoom_slider_value_changed(value: float) -> void:
	if !Stage.instance.can_control: return
	zoom.x = lerpf(min_zoom,max_zoom,value)
	zoom.y = zoom.x
	zoom_clamp()
	pass # Replace with function body.
