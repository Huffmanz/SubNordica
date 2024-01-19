class_name EnemyUnit
extends Unit


@export var process = false
@onready var animated_sprite_2d = $Visuals/AnimatedSprite2D

func _ready():
	super._ready()
	walk_started.connect(on_walk_started)
	walk_finished.connect(on_walk_finished)
	
	GameEvents.level_started.connect(on_level_started)

func on_level_started():
	process = true

func on_walk_started():
	animated_sprite_2d.play("move")

func on_walk_finished():
	animated_sprite_2d.play("default")

func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if !process:
		projectile_spawner_component.Stop()
		return
	var target = acquire_target_component.acquire_target(attack_range)
	if _is_walking:
		follow_path(delta)
		projectile_spawner_component.Stop()
	elif target == Vector2.ZERO:
		projectile_spawner_component.Stop()
		target = acquire_target_component.acquire_target(10000)
		if target != Vector2.ZERO:
			GameEvents.enemy_move_request.emit(self, attack_range, target)
	else:
		projectile_spawner_component.Start()
		var shoot_direction = target - projectile_spawner_component.global_position
		var angleTo = shoot_direction.angle()
		var current_rotation = projectile_spawner_component.global_rotation
		var angle = lerp_angle(current_rotation , angleTo, 1)
		angle = clamp(angle, current_rotation - 100 * delta, current_rotation + 100 * delta)
		projectile_spawner_component.global_rotation = angle
	follow_path(delta)
