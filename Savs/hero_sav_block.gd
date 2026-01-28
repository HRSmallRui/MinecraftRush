extends Resource
class_name HeroSavBlock

@export var hero_level: int = 1
@export var hero_exp: int = 0
@export var unlocked: bool = false
@export var skill_levels: Array[int] = [0,0,0,0,0]
@export var current_skill_point: int

static var hero_sav_block_library = {
	0: HeroSavBlock.new(1,0,true),
	1: HeroSavBlock.new(2,4),
	2: HeroSavBlock.new(3,8),
	3: HeroSavBlock.new(4,12),
	4: HeroSavBlock.new(5,16),
	5: HeroSavBlock.new(5,16),
	6: HeroSavBlock.new(5,16),
	7: HeroSavBlock.new(5,16),
	8: HeroSavBlock.new(5,16),
	9: HeroSavBlock.new(6,20),
	10: HeroSavBlock.new(5,16), ##余瓦娜
}

static var hero_unlocked_levels = {
	0: 0,
	1: 3,
	2: 6,
	3: 10,
	100: 20
}


func _init(level: int = 1,current_skill_points: int = 0,unlocked: bool = false,skill_levels: Array[int] = [0,0,0,0,0],exp: int = 0) -> void:
	hero_level = level
	current_skill_point = current_skill_points
	unlocked = unlocked
	skill_levels = skill_levels
	self.hero_exp = exp
	pass
