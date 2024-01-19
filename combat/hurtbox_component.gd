extends Area2D
class_name HurboxComponent

signal hit

@export var health_component: Node
@export var damage_audio_player: RandomAudioStreamPlayer

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
	hit.emit()
