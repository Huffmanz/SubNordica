@tool
class_name Unit
extends Path2D

signal walk_started
signal walk_finished
signal range_updated
signal attack_range_updated(new_attack_range: float)
signal heal_percent_updated(new_heal_percent: float)

@export var grid: Grid = preload("res://resources/grid_32.tres")
@export var move_range := 0 : set = set_move_range
@export var move_speed := 1.0
@export var crew := 5
@export var max_attack_range: = 1000

@onready var attack_range = max_attack_range
@onready var heal_timer = $HealTimer
@onready var death_audio_player = $DeathAudioPlayer

var explosion_scene = preload("res://vfx/explosion_effect.tscn")

var crew_unassigned
var crew_assigned_movement = 0  
var crew_assigned_attack = 0
var crew_assigned_heal = 0

var current_heal_percent = 0.0

var cell := Vector2.ZERO: set = set_cell
var is_selected := false: set = set_is_selected

var _is_walking := false : set = _set_is_walking

@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var projectile_spawner_component = $Visuals/ProjectileSpawnerComponent
@onready var acquire_target_component = $Visuals/AcquireTargetComponent
@onready var range_indicator = $Visuals/RangeIndicator
@onready var health_component:HealthComponent = $Visuals/HealthComponent

var current_target
var base_range

var wreckage = preload("res://unit/wreckage.tscn")

func _ready() -> void:
	crew_unassigned = crew
	#set_process(false)
	range_indicator.visible = false
	
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	heal_timer.timeout.connect(on_heal_timer_timeout)

	if not Engine.is_editor_hint():
		curve = Curve2D.new()
	health_component.died.connect(on_died)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	var target = acquire_target_component.acquire_target(attack_range)
	if target == Vector2.ZERO || _is_walking:
		projectile_spawner_component.Stop()
	else:
		projectile_spawner_component.Start()
		var shoot_direction = target - projectile_spawner_component.global_position
		var angleTo = shoot_direction.angle()
		var current_rotation = projectile_spawner_component.global_rotation
		var angle = lerp_angle(current_rotation , angleTo, 1)
		angle = clamp(angle, current_rotation - 100 * delta, current_rotation + 100 * delta)
		projectile_spawner_component.global_rotation = angle
	
	follow_path(delta)


func follow_path(delta : float):
	if curve.point_count > 0:
		_path_follow.progress_ratio += (move_speed / curve.get_baked_length()) / 10 * delta 
	
	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		_path_follow.progress_ratio = 0.0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true
	walk_started.emit()


func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	range_indicator.visible = is_selected
	range_indicator.scale = Vector2(attack_range / 16.0,attack_range  / 16.0)
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func set_move_range(value: int) -> void:
	move_range = value
	range_updated.emit()
	
func change_move_range(difference: int):
	difference = update_crew_unassigned(difference)
	crew_assigned_movement = clamp(crew_assigned_movement + difference, 0, crew)
	var value = clamp(move_range + difference, 0, crew_assigned_movement + crew_unassigned)
	move_range = value
	range_updated.emit()
	
func update_crew_unassigned(difference: int) -> int:
	if crew_unassigned == 0 and difference > 0: return 0
	if crew_unassigned == crew and difference < 0: return 0	
	
	crew_unassigned =  clamp(crew_unassigned - difference, 0, crew)
	return difference

func change_attack_range(difference: int):
	difference = update_crew_unassigned(difference)
	crew_assigned_attack = clamp(crew_assigned_attack + difference, 0, crew)
	var max_percent_increase = 1 + .25 * crew
	var percent_increase = 1 + .25 * crew_assigned_attack
	var new_attack_range = max_attack_range * percent_increase
	attack_range = clamp(new_attack_range, max_attack_range, max_attack_range * max_percent_increase)
	attack_range_updated.emit(attack_range)
	range_indicator.scale = Vector2(attack_range / 16.0,attack_range  / 16.0)
	
func change_heal_crew(difference: int):
	difference = update_crew_unassigned(difference)
	crew_assigned_heal = clamp(crew_assigned_heal + difference, 0, crew)
	if crew_assigned_heal == 0:
		current_heal_percent = 0
		heal_timer.stop()
		heal_percent_updated.emit(current_heal_percent)
		return
	var max_percent_increase = .1 * crew
	var new_heal_percent = .1 * crew_assigned_heal
	current_heal_percent = clampf(new_heal_percent, 0, max_percent_increase)
	heal_percent_updated.emit(current_heal_percent)
	heal_timer.start()
	
func on_heal_timer_timeout():
	var heal_amount = health_component.max_health * current_heal_percent
	if health_component.get_health_percent() == 1: return
	health_component.heal(health_component.max_health * current_heal_percent)
	
func _set_is_walking(value: bool) -> void:
	_is_walking = value
	
func on_died():
	var grid_pos = grid.calculate_grid_coordinates(_path_follow.global_position)
	var world_pos = grid.calculate_map_position(grid_pos)
	Utils.instantiate_scene_on_world(wreckage, world_pos)
	for i in range(5):
		Utils.instantiate_scene_on_world(explosion_scene, world_pos + Vector2(randf_range(-8,8),randf_range(-8,8)))
	death_audio_player.play_random()
	await death_audio_player.finished
	queue_free()
