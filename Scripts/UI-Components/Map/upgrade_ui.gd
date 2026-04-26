extends Control
class_name UpgradeUI

signal update
signal quit

var can_use_stars: int
var tech_levels: Array[int]
var can_control: bool


func _ready() -> void:
	var sav = Map.instance.current_sav as GameSaver
	$SkillIntroPanel.hide()
	can_use_stars = sav.can_use_stars
	tech_levels = sav.upgrade_sav.duplicate(true)
	update.connect(update_star_label)
	update.emit()
	
	await $AnimationPlayer.animation_finished
	can_control = true
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		_on_finish_button_pressed()
	pass


func _on_finish_button_pressed() -> void:
	quit_animation()
	Map.instance.current_sav.can_use_stars = can_use_stars
	Map.instance.current_sav.upgrade_sav = tech_levels
	Global.sav_game_sav(Map.instance.current_sav)
	pass # Replace with function body.


func _on_cancel_button_pressed() -> void:
	can_use_stars = Map.instance.current_sav.can_use_stars
	tech_levels = Map.instance.current_sav.upgrade_sav.duplicate(true)
	update.emit()
	pass # Replace with function body.


func _on_reset_button_pressed() -> void:
	can_use_stars = Map.instance.current_sav.total_stars
	tech_levels = [0,0,0,0,0,0]
	update.emit()
	pass # Replace with function body.


func quit_animation():
	can_control = false
	quit.emit()
	$AnimationPlayer.play("Exit")
	await $AnimationPlayer.animation_finished
	Map.instance.can_control = true
	queue_free()
	pass


func _process(delta: float) -> void:
	$SkillIntroPanel.global_position = get_global_mouse_position() + Vector2(20,20)
	pass


func show_panel(skill_type,skill_level):
	$SkillIntroPanel.show()
	$SkillIntroPanel/NameLabel.text = UpgradeLibrary.skill_names[skill_type][skill_level-1]
	$SkillIntroPanel/IntroLabel.text = UpgradeLibrary.skill_intros[skill_type][skill_level-1]
	$SkillIntroPanel/PriceLabel.text = str(UpgradeLibrary.skill_prices[skill_type][skill_level-1])
	pass


func hide_panel():
	$SkillIntroPanel.hide()
	pass


func update_star_label():
	$ShowStarBar/Label.text = str(can_use_stars)
	pass


func level_up(skill_type,skill_level,cost_stars: int):
	$LevelUpAudio.play(0.07)
	can_use_stars -= cost_stars
	tech_levels[skill_type] = skill_level
	update.emit()
	pass
