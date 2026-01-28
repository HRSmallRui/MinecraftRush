extends Line2D
class_name ProtectorChurchRay

@export var start_point: Node2D
@export var end_point: Node2D
@export var ray_level: int:
	set(level):
		if level < 6:
			ray_level = level
			width = level_width[ray_level]
@export var level_width: Array[float]

@onready var start_point_particle: GPUParticles2D = $StartPointParticle
@onready var end_point_particle: GPUParticles2D = $EndPointParticle


func _ready() -> void:
	for wid in level_width:
		wid *= 5
	points.clear()
	points = PackedVector2Array([start_point.global_position - global_position,end_point.global_position - global_position])
	start_point_particle.position = points[0]
	end_point_particle.position = points[1]
	pass


func _process(delta: float) -> void:
	if end_point == null: 
		disappear()
		set_process(false)
		return
	points = PackedVector2Array([start_point.global_position - global_position,end_point.global_position - global_position])
	if get_tree().paused: $AnimationPlayer.play("2")
	else: $AnimationPlayer.play("1")
	start_point_particle.position = points[0]
	end_point_particle.position = points[1]
	#points = PackedVector2Array([start_point.global_position,end_point.global_position])
	pass


func disappear():
	set_process(false)
	var hide_tween: Tween = create_tween()
	hide_tween.tween_property(self,"width",0,0.4)
	await hide_tween.finished
	queue_free()
	pass
