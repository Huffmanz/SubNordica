class_name FireComponent
extends Node2D

@export var health_component: HealthComponent
@export var damage_particles: Array[GPUParticles2D]
@onready var damage_timer = $DamageTimer
@onready var fire_area = $FireArea
@onready var receive_fire = $ReceiveFire

var current_damage_particles: Array[GPUParticles2D]
var particles_in_use: Array[GPUParticles2D] = []
var health_breakdowns: Array[float]
var floating_text_scene = preload("res://ui/red_floating_text.tscn")
@onready var collision_shape_2d = $FireArea/CollisionShape2D
@onready var fire_indicator = $FireIndicator
@onready var damage_audio_player = $DamageAudioPlayer

var fire_level = 0

func _ready():
	health_component.health_changed.connect(on_health_changed)
	var health_breakdown = 1.0 / (len(damage_particles) + 1)
	var left = 1.0 - health_breakdown
	while left > 0:
		health_breakdowns.append(left)
		left -= health_breakdown
	current_damage_particles = damage_particles
	damage_timer.timeout.connect(on_damage_timer_timeout)
	receive_fire.area_entered.connect(on_receive_fire_entered)
	fire_indicator.visible = false
	fire_area.monitorable = false
	fire_area.monitoring = false
	
func on_health_changed():
	#if len(current_damage_particles) == 0:
	#	return
	var health_percent = health_component.get_health_percent()
	var health_breakdowns_left = health_breakdowns.filter(func (a: float):
		return a < health_percent
	)
	if len(health_breakdowns_left) < len(current_damage_particles):
		var particle: GPUParticles2D = current_damage_particles.pop_back()
		fire_level += 1
		particle.emitting = true
		particles_in_use.append(particle)
		damage_timer.start()
		
	if len(current_damage_particles) == 0:
		fire_indicator.visible = true
		fire_area.set_deferred("monitorable", true)
		fire_area.set_deferred("monitoring", true)
		
	if len(health_breakdowns_left) > len(current_damage_particles):
		if len(current_damage_particles) != 1 || health_percent == 1.0:
			var particle: GPUParticles2D = particles_in_use.pop_back()
			particle.emitting = false
			current_damage_particles.append(particle)
			
	if health_percent == 1.0:
		for particle in particles_in_use:
			particle.emitting = false
			current_damage_particles.append(particle)
		particles_in_use = []
		fire_level = 0
		fire_indicator.visible = false
		damage_timer.stop()
	
func on_damage_timer_timeout():
	var damage = health_component.max_health * .05 * fire_level
	health_component.damage(damage)
	var floating_text = Utils.instantiate_scene_on_world(floating_text_scene, global_position + (Vector2.UP * randf_range(2,20))+ (Vector2.RIGHT * randf_range(-8.0,8.0)))
	var format_screen = "-%0.0f"
	floating_text.start(format_screen % damage)
	damage_audio_player.play_random()
	await damage_audio_player.finished
		
func on_receive_fire_entered(other_area: Area2D):
	if !other_area.get_parent()  is FireComponent: return
	if other_area.get_parent() == self: return
	if other_area.get_parent().fire_level == 0: return
	fire_level = 1
	damage_timer.start()

