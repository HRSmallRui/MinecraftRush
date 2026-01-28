extends CanvasLayer

@export var linked_hero: Hero
@export var normal_bar_texture: AtlasTexture
@export var hover_bar_texture: AtlasTexture

@onready var hero_unit_button: TextureButton = $HeroUnitButton
@onready var health_progress_bar: TextureProgressBar = $HeroUnitButton/HealthProgressBar
@onready var xp_progress_bar: TextureProgressBar = $HeroUnitButton/XP_ProgressBar
@onready var hero_level_label: Label = $HeroUnitButton/HeroLevelLabel
@onready var rebirth_progress_bar: TextureProgressBar = $HeroUnitButton/RebirthProgressBar
@onready var hero_texture: TextureRect = $HeroUnitButton/HeroTexture


func _ready() -> void:
	Stage.instance.ui_update.connect(ui_process)
	
	if OS.get_name() == "Android":
		hero_unit_button.scale *= 1.2
		$AnimationPlayer.play("entry_mobile")
		hero_unit_button.texture_hover = normal_bar_texture
	
	#hero_unit_button.scale *= 1.2
	#$AnimationPlayer.play("entry_mobile")
	pass


func _process(delta: float) -> void:
	hero_texture.modulate = Color.GRAY if linked_hero.ally_state == Ally.AllyState.DIE else Color.WHITE
	rebirth_progress_bar.value = linked_hero.rebirth_timer.time_left / linked_hero.rebirth_time
	hero_unit_button.disabled = linked_hero.ally_state == Ally.AllyState.DIE
	health_progress_bar.value = float(linked_hero.current_data.health) / linked_hero.start_data.health
	hero_level_label.text = str(linked_hero.hero_level)
	if linked_hero.hero_level == 10:
		xp_progress_bar.value = 1
	else:
		xp_progress_bar.value = float(linked_hero.hero_exp) / Hero.hero_level_xps[linked_hero.hero_level-1]
	pass


func ui_process(member: Node):
	if member == linked_hero:
		hero_unit_button.texture_normal = hover_bar_texture
	else:
		hero_unit_button.texture_normal = normal_bar_texture
	
	if OS.get_name() == "Android":
		hero_unit_button.texture_hover = hero_unit_button.texture_normal
	pass


func _on_hero_unit_button_pressed() -> void:
	if Stage.instance.information_bar.current_check_member == linked_hero:
		Stage.instance.ui_process(null)
		MobileMiddleProcess.instance.current_touch_object = null
	else: 
		Stage.instance.ui_process(linked_hero,Stage.StageUI.Move)
		MobileMiddleProcess.instance.current_touch_object = linked_hero
	pass # Replace with function body.
