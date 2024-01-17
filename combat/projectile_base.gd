class_name Projectile
extends CharacterBody2D

@onready var hitbox_component = $HitboxComponent
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var hit_audio_player = $HitAudioPlayer

var spawn_location : Vector2
var collided := false

@export var speed = 250.0
@onready var hitbox = $HitboxComponent
@onready var sprite_2d = $Sprite2D

var explosion_effect_scene = preload("res://vfx/explosion_effect.tscn")

func _ready():
	hitbox.area_entered.connect(on_hitbox_area_entered)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func _process(delta):
	if velocity == Vector2.ZERO:
		velocity.x = speed
		velocity = velocity.rotated(rotation)
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func on_hitbox_area_entered(area: Area2D):
	hitbox_component.queue_free()
	sprite_2d.queue_free()
	Utils.instantiate_scene_on_world(explosion_effect_scene, global_position)
	hit_audio_player.play_random()
	GameEvents.add_screenshake.emit(1.0, .25)
	await hit_audio_player.finished
	queue_free()
