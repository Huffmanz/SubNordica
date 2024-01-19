class_name HealthComponent
extends Node2D

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10
var current_health 
var dead = false

var floating_text_scene = preload("res://ui/floating_text.tscn")

func _ready():
	current_health = max_health

func damage(damage_amount: float):
	current_health = clamp(current_health-damage_amount, 0, max_health)
	health_changed.emit()
	health_decreased.emit()
	var floating_text = Utils.instantiate_scene_on_world(floating_text_scene, global_position + (Vector2.UP * randf_range(2,20))+ (Vector2.RIGHT * randf_range(-16.0,16.0)))
	var	format_screen = "-%0.0f"
	floating_text.start(format_screen % damage_amount)
	Callable(check_death).call_deferred()
	
func heal(heal_amount: float):
	current_health = clamp(current_health+heal_amount, 0, max_health)
	var floating_text = Utils.instantiate_scene_on_world(floating_text_scene, global_position + (Vector2.UP * randf_range(2,20))+ (Vector2.RIGHT * randf_range(-16.0,16.0)))
	var	format_screen = "+%0.0f"
	floating_text.start(format_screen % heal_amount)
	health_changed.emit()
	
func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)
	
func check_death():
	if dead: return
	if current_health <= 0:
		dead = true
		died.emit()
		
