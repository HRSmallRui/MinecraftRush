extends Node2D
class_name ExtraContent

enum ExtraUIState{
	None,
	BigMap,
	Book,
	Desk,
	Bed,
	Tomb
}

@export var can_control: bool = true
@export var book_ui_scene: PackedScene
@export var big_map_ui_scene: PackedScene
@export var bed_ui_scene: PackedScene
@export var desk_ui_scene: PackedScene

static var instance: ExtraContent

@onready var extra_start: AudioStreamPlayer = $ExtraStart
@onready var extra_loop: AudioStreamPlayer = $ExtraLoop
@onready var ui_animation_player: AnimationPlayer = $UIAnimationPlayer
@onready var ui_layer: CanvasLayer = $UILayer

var ui_state: ExtraUIState = ExtraUIState.None


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	await get_tree().create_timer(21.98,true,true).timeout
	extra_loop.play()
	pass


func _input(event: InputEvent) -> void:
	if can_control and event.is_action_released("escape"):
		back()
	pass


func _on_map_button_pressed() -> void:
	if can_control and ui_state == ExtraUIState.None:
		ui_animation_player.play("map")
		ui_state = ExtraUIState.BigMap
		can_control = false
		ui_layer.add_child(big_map_ui_scene.instantiate())
		await ui_animation_player.animation_finished
		can_control = true
	pass # Replace with function body.


func _on_book_button_pressed() -> void:
	if can_control and ui_state == ExtraUIState.None:
		ui_animation_player.play("book")
		ui_state = ExtraUIState.Book
		can_control = false
		ui_layer.add_child(book_ui_scene.instantiate())
		await ui_animation_player.animation_finished
		can_control = true
	pass # Replace with function body.


func _on_desk_button_pressed() -> void:
	if can_control and ui_state == ExtraUIState.None:
		ui_animation_player.play("desk")
		ui_state = ExtraUIState.Desk
		can_control = false
		ui_layer.add_child(desk_ui_scene.instantiate())
		await ui_animation_player.animation_finished
		can_control = true
	pass # Replace with function body.


func _on_bed_button_pressed() -> void:
	if can_control and ui_state == ExtraUIState.None:
		ui_animation_player.play("bed")
		ui_state = ExtraUIState.Bed
		can_control = false
		ui_layer.add_child(bed_ui_scene.instantiate())
		await ui_animation_player.animation_finished
		can_control = true
	pass # Replace with function body.


func _on_tomb_button_pressed() -> void:
	if can_control and ui_state == ExtraUIState.None:
		ui_animation_player.play("tomb")
		ui_state = ExtraUIState.Tomb
		can_control = false
		await ui_animation_player.animation_finished
		can_control = true
	pass # Replace with function body.


func back():
	match ui_state:
		ExtraUIState.BigMap:
			ui_animation_player.play_backwards("map")
			can_control = false
			await ui_animation_player.animation_finished
			can_control = true
			ui_state = ExtraUIState.None
		ExtraUIState.Book:
			ui_animation_player.play_backwards("book")
			can_control = false
			await ui_animation_player.animation_finished
			can_control = true
			ui_state = ExtraUIState.None
		ExtraUIState.Desk:
			ui_animation_player.play_backwards("desk")
			can_control = false
			await ui_animation_player.animation_finished
			can_control = true
			ui_state = ExtraUIState.None
		ExtraUIState.Bed:
			ui_animation_player.play_backwards("bed")
			can_control = false
			await ui_animation_player.animation_finished
			can_control = true
			ui_state = ExtraUIState.None
		ExtraUIState.Tomb:
			ui_animation_player.play_backwards("tomb")
			can_control = false
			await ui_animation_player.animation_finished
			can_control = true
			ui_state = ExtraUIState.None
	pass
