extends TextureRect
class_name SkillCheck

@export var skill_name: String
@export_multiline var skill_intro: String
@export var intro_panel: Panel
@export var intro_name_label: Label
@export var intro_label: Label

@onready var label: Label = $Label


func _ready() -> void:
	label.text = skill_name
	pass


func _on_mouse_entered() -> void:
	intro_panel.show()
	intro_name_label.text = skill_name
	intro_label.text = skill_intro
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	intro_panel.hide()
	pass # Replace with function body.
