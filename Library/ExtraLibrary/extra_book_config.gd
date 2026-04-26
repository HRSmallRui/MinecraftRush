extends Resource
class_name ExtraBookConfig

@export var title: String
@export_multiline var content: String
@export_file() var background_texture_path: String
@export var texture_alpha: float = 0.4
@export var unlock_tag: String = "normal"
