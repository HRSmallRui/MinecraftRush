extends StoryLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var bgm: AudioStreamPlayer = $BGM


func _ready() -> void:
	super()
	color_rect.modulate.a = 0
	create_tween().tween_property(color_rect,"modulate:a",1,1)
	bgm.volume_db = -100
	create_tween().tween_property(bgm,"volume_db",0,1)
	pass


func disappear():
	super()
	create_tween().tween_property(bgm,"volume_db",-100,0.8)
	pass
