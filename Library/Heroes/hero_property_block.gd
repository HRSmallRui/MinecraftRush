extends Resource
class_name HeroPropertyBlock

@export var hero_name: String ##名字
@export var hero_subname: String ##称号
@export_multiline var hero_intro: String ##介绍
@export var hero_type: Ally.AllyGroup
@export var max_healths: Array[int] = [0,0,0,0,0,0,0,0,0,0]
@export var damage_nears: Array[DamageBlock]
@export var damage_near_speed: float
@export var damage_fars: Array[DamageBlock]
@export var damage_far_speed: float
@export var damage_far_range: int
@export var armors: Array[float] = [0,0,0,0,0,0,0,0,0,0]
@export var magic_defences: Array[float] = [0,0,0,0,0,0,0,0,0,0]
@export var xp_speed_rate: float
@export var move_speed: float
@export var hero_poster: Texture2D
