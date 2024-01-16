extends Area2D
class_name HurboxComponent

signal hit

@export var health_component: Node
@export var damage_audio_player: RandomAudioStreamPlayer

var floating_text_scene = preload("res://ui/floating_text.tscn")

func _ready():
	area_entered.connect(on_area_entered)
	
func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	if health_component == null:
		return
		
	var hitbox_component = other_area as HitboxComponent
	health_component.damage(hitbox_component.damage)
	if damage_audio_player != null: 
		damage_audio_player.play_random()
	var floating_text = Utils.instantiate_scene_on_world(floating_text_scene, global_position + (Vector2.UP * randf_range(2,20))+ (Vector2.RIGHT * randf_range(-16.0,16.0)))
	var format_screen = "-%0.1f"
	if round(hitbox_component.damage) == hitbox_component.damage:
		format_screen = "-%0.0f"
	floating_text.start(format_screen % hitbox_component.damage)
	hit.emit()
