extends ShooterBullet

@export var explosion_damage: DamageBlock
@export var explosion_scene: PackedScene
@export var smoke_scene: PackedScene

@onready var explosion_area: Area2D = $ExplosionArea


func _ready() -> void:
	super()
	explosion_area.position = target_position
	pass


func _on_straight_move_finished() -> void:
	for body in explosion_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = randi_range(explosion_damage.damage_low,explosion_damage.damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = explosion_area.position
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = explosion_area.position
	Stage.instance.bullets.add_child(smoke_effect)
	AudioManager.instance.play_explosion_audio()
	var show_text: String
	match randi_range(0,1):
		0: show_text = "轰！"
		1: show_text = "砰！"
	TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Bombard,position + Vector2(0,-40))
	queue_free()
	pass # Replace with function body.
