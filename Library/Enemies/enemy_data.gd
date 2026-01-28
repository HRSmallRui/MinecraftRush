extends Resource
class_name EnemyData

var enemy_name: String #敌人名称
var enemy_intro: String #敌人介绍
var enemy_health: int #敌人生命
var damage_low: int #敌人攻击下限
var damage_high: int #敌人攻击上限
var enemy_armor: float #敌人护甲
var enemy_magic_defence: float #敌人魔抗
var enemy_move_speed: float #敌人速度
var lives_taken: int #代价
var notifition_tags: String #新提示属性
var seen_book_tag: String #图鉴词条

func _init(in_name: String,intro: String, max_health: int,in_damage_low: int,in_damage_high: int,
armor: float,magic_defence: float,move_speed: float,payment: int, notifition_tag: String,seen_book_tags: String = "") -> void:
	enemy_name = in_name
	enemy_intro = intro
	enemy_health = max_health
	damage_low = in_damage_low
	damage_high = in_damage_high
	enemy_armor = armor
	enemy_magic_defence = magic_defence
	enemy_move_speed = move_speed
	lives_taken = payment
	notifition_tags = notifition_tag
	seen_book_tag = seen_book_tags
	pass
