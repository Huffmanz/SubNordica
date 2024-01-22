class_name FireComponent
extends Node2D

@export var health_component: HealthComponent
@export var damage_particles: Array[GPUParticles2D]

@onready var damage_timer = $DamageTimer
@onready var fire_area = $FireArea
@onready var receive_fire = $ReceiveFire
@onready var fire_indicator = $FireIndicator
@onready var damage_audio_player = $DamageAudioPlayer

var health_breakdowns: Array[float]


var fire_level = 0
var caught_fire = false

func _ready():
	health_component.health_changed.connect(on_health_changed)
	var health_breakdown = 1.0 / (len(damage_particles) + 1)
	var left = 1.0 - health_breakdown
	while left > 0:
		health_breakdowns.append(left)
		left -= health_breakdown
	damage_timer.timeout.connect(on_damage_timer_timeout)
	receive_fire.area_entered.connect(on_receive_fire_entered)
	fire_indicator.visible = false
	fire_area.monitorable = false
	fire_area.monitoring = false
	
func on_health_changed():

	var health_percent = health_component.get_health_percent()
	var health_breakdowns_left = health_breakdowns.filter(func (a: float):
		return a < health_percent
	)
	
	fire_level = len(health_breakdowns) - len(health_breakdowns_left)
	
	if caught_fire:
		fire_level = max(1, fire_level)
	if fire_level > 0:
		damage_timer.start()
		
	var count = 0
	for particle: GPUParticles2D in damage_particles:
		if particle.emitting and count < fire_level:
			count += 1
		elif particle.emitting and count >= fire_level:
			particle.emitting = false
		elif !particle.emitting and count < fire_level:
			particle.emitting = true
			count += 1
		elif !particle.emitting and count >= fire_level:
			particle.emitting = false
		
	# when to start other things on fire
	if len(health_breakdowns_left) == 0:
		fire_indicator.visible = true
		fire_area.set_deferred("monitorable", true)
		fire_area.set_deferred("monitoring", true)
	
	if health_percent == 1.0:
		fire_level = 0
		fire_indicator.visible = false
		caught_fire = false
		damage_timer.stop()
	
func on_damage_timer_timeout():
	var damage = health_component.max_health * .05 * fire_level
	health_component.damage(damage)
	damage_audio_player.play_random()
	await damage_audio_player.finished
		
func on_receive_fire_entered(other_area: Area2D):
	if other_area.get_parent() == self: return
	caught_fire = true
	fire_level = max(1, fire_level) #keep current fire level if one
	damage_timer.start()

