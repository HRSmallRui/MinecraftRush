extends Node
class_name AudioManager

static var instance: AudioManager

@onready var lose_heart_audio: AudioStreamPlayer = $LoseHeartAudio
@onready var wave_coming_audio: AudioStreamPlayer = $WaveComingAudio
@onready var wave_summon_audio: AudioStreamPlayer = $WaveSummonAudio
@onready var shoot_audio_1: AudioStreamPlayer = $ShootAudio1
@onready var arrow_hit_1: AudioStreamPlayer = $ArrowHit1
@onready var arrow_hit_2: AudioStreamPlayer = $ArrowHit2
@onready var magic_shot_audio: AudioStreamPlayer = $MagicShotAudio
@onready var dead_body_explosion_audio: AudioStreamPlayer = $DeadBodyExplosionAudio
@onready var bombard_shoot_1: AudioStreamPlayer = $BombardShoot1
@onready var boom_1: AudioStreamPlayer = $ExplosionShell/Boom1
@onready var boom_2: AudioStreamPlayer = $ExplosionShell/Boom2
@onready var boom_3: AudioStreamPlayer = $ExplosionShell/Boom3
@onready var boom_4: AudioStreamPlayer = $ExplosionShell/Boom4
@onready var tower_sell_audio: AudioStreamPlayer = $TowerSellAudio
@onready var level_up_audio: AudioStreamPlayer = $Hero/LevelUpAudio
@onready var fork_throw_1: AudioStreamPlayer = $ForkThrow1
@onready var fork_throw_2: AudioStreamPlayer = $ForkThrow2
@onready var shoot_audio_2: AudioStreamPlayer = $ShootAudio2
@onready var stone_explosion_audio: AudioStreamPlayer = $StoneExplosionAudio
@onready var black_stone_hit_audio: AudioStreamPlayer = $BlackStoneHitAudio
@onready var witch_shot_audio: AudioStreamPlayer = $WitchShotAudio
@onready var magic_shoot_heavy_audio: AudioStreamPlayer = $MagicShootHeavyAudio

var registor_enemy_entry_audio_list: Array[String]
var is_the_explosion_frame: bool = false
var registor_oneshot_audio_list: Array[AudioStream]
var registor_enemy_entry_stream_list: Array[AudioStream]


func _init() -> void:
	instance = self
	pass


func play_explosion_audio():
	match randi_range(0,3):
		0: 
			if boom_1.stream in registor_oneshot_audio_list: return
			boom_1.play()
			registor_oneshot_audio_list.append(boom_1.stream)
			await get_tree().process_frame
			registor_oneshot_audio_list.erase(boom_1.stream)
		1: 
			if boom_2.stream in registor_oneshot_audio_list: return
			boom_2.play()
			registor_oneshot_audio_list.append(boom_2.stream)
			await get_tree().process_frame
			registor_oneshot_audio_list.erase(boom_2.stream)
		2: 
			if boom_3.stream in registor_oneshot_audio_list: return
			boom_3.play()
			registor_oneshot_audio_list.append(boom_3.stream)
			await get_tree().process_frame
			registor_oneshot_audio_list.erase(boom_3.stream)
		3: 
			if boom_4.stream in registor_oneshot_audio_list: return
			boom_4.play()
			registor_oneshot_audio_list.append(boom_4.stream)
			await get_tree().process_frame
			registor_oneshot_audio_list.erase(boom_4.stream)
	pass


func battle_audio_play():
	var battle_audio: AudioStreamPlayer = $Battle.get_child(randi_range(0,$Battle.get_child_count()-1))
	battle_audio.play()
	pass


func entry_audio_registor(entry_label: String):
	registor_enemy_entry_audio_list.append(entry_label)
	await get_tree().create_timer(15,false).timeout
	registor_enemy_entry_audio_list.erase(entry_label)
	pass


func entry_stream_registor(stream: AudioStream):
	registor_enemy_entry_stream_list.append(stream)
	await get_tree().create_timer(15,false).timeout
	registor_enemy_entry_stream_list.erase(stream)
	pass


func explosion_dead_body_audio_play():
	if !is_the_explosion_frame:
		is_the_explosion_frame = true
		dead_body_explosion_audio.play()
		await get_tree().process_frame
		is_the_explosion_frame = false
	pass


func oneshot_audio_registor(oneshot_stream: AudioStream):
	registor_oneshot_audio_list.append(oneshot_stream)
	await get_tree().create_timer(0.2,false).timeout
	registor_oneshot_audio_list.erase(oneshot_stream)
	pass


func oneshot_frame_free_audio_regist(oneshot_stream: AudioStream):
	registor_oneshot_audio_list.append(oneshot_stream)
	await get_tree().process_frame
	registor_oneshot_audio_list.erase(oneshot_stream)
	pass


func play_fork_throw_audio():
	match randi_range(0,1):
		0: fork_throw_1.play()
		1: fork_throw_2.play()
	pass


func play_water_audio():
	match randi_range(1,3):
		1: $WaterAudio/WaterAudio1.play()
		2: $WaterAudio/WaterAudio2.play()
		3: $WaterAudio/WaterAudio3.play()
	pass
