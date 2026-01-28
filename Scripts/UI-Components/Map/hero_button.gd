extends TextureButton

@export var hero_id: int = 0
@export var hero_skill_intro_list: Array[HeroSkillTextBlock] = [
	null,null,null,null,null
]

@onready var hero_hall: HeroHall = $"../../.."
@onready var hero_select_sprite: Sprite2D = $HeroSelectSprite


func _ready() -> void:
	hero_hall.select_hero.connect(select_hero)
	if hero_id == Map.instance.current_sav.select_hero_id:
		await get_tree().process_frame
		_pressed()
	hero_select_sprite.visible = Map.instance.current_sav.select_hero_id == hero_id
	pass


func _process(delta: float) -> void:
	if OS.get_name() == "Android":
		if get_draw_mode() == DrawMode.DRAW_NORMAL:
			modulate = Color.WHITE
		elif get_draw_mode() == DrawMode.DRAW_PRESSED:
			modulate = Color.WHITE * 1.5
		return
	if get_draw_mode() == DrawMode.DRAW_NORMAL or get_draw_mode() == DrawMode.DRAW_PRESSED:
		modulate = Color.WHITE
	elif get_draw_mode() == DrawMode.DRAW_HOVER:
		modulate = Color.WHITE * 1.5
	pass


func _pressed() -> void:
	hero_hall.change_hero(hero_id)
	HeroHall.instance.hero_skill_intro_list = hero_skill_intro_list
	MobileMiddleProcess.instance.current_touch_object = self
	pass


func select_hero(new_hero_id: int):
	hero_select_sprite.visible = new_hero_id == hero_id
	pass
