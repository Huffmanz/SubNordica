class_name ProjectileSpawnerComponent
extends Node2D

signal shot

@export var spawn_location: Marker2D
@export var projectile: PackedScene
@export var shoot_timer: Timer

@export var burst_count = 1

@onready var random_audio_player = $RandomAudioPlayer

@onready var time_between_burst_shots = $TimeBetweenBurstShots
var shots_left
var can_fire = false

func _ready():
	shoot_timer.timeout.connect(on_shoot_timer_timeout)
	shoot_timer.start()
	shoot_timer.one_shot = false
	time_between_burst_shots.timeout.connect(on_burst_timeout)


func Shoot():
	if shots_left <= 0:
		return
	
	random_audio_player.play_random()
	shot.emit()
	var projectile_instance = Utils.instantiate_scene_on_world(projectile, spawn_location.global_position)
	projectile_instance.rotation = global_rotation	
	shots_left -= 1

	if shots_left <= 0:
		Start()
	else:
		time_between_burst_shots.start()

func Stop():
	shoot_timer.stop()
	
func Start():
	if shoot_timer.is_stopped():
		shoot_timer.start()
	

func on_shoot_timer_timeout():
	Stop()
	shots_left = burst_count
	Shoot()
	
func on_burst_timeout():
	Shoot()
