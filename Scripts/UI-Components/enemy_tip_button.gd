extends Control
class_name TipButton

@export var open_tip_scene: PackedScene
@export var id: int

@onready var texture_button: TextureButton = $Button/TextureButton

func _ready() -> void:
	var front_path: String = "res://Assets/Images/UI/TipIcons/enemy-"
	texture_button.texture_normal = load(front_path + str(id) + ".png")
	texture_button.texture_pressed = texture_button.texture_normal
	texture_button.texture_hover = load(front_path + str(id) + "-hover.png")
	texture_button.pressed.connect(show_tip)
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("loop")
	pass


func show_tip():
	var new_node = open_tip_scene.instantiate()
	if new_node is EnemyTip: new_node.enemy_id = id
	Stage.instance.add_child(new_node)
	queue_free()
	pass
