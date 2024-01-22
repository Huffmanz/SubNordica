extends Node2D

@export var next_level :PackedScene
@export var level_start_timer: Timer
@export var game_board: GameBoard
@onready var game_over = $GameOver

var enemy_count: int
var player_count: int

func _ready():
	level_start_timer.timeout.connect(on_level_start_timer_timeout)
	var grid := game_board.grid
	var limit = game_board.grid.calculate_map_position(grid.cell_size)
	GameEvents.camera_limits_changed.emit(
		0,
		limit.x ,
		0,
		limit.y
	)
	GameEvents.player_unit_destroyed.connect(on_player_unit_destroyed)
	GameEvents.enemy_unit_destroyed.connect(on_enemy_unit_destroyed)
	enemy_count = len(get_tree().get_nodes_in_group("EnemyUnit"))
	player_count = len(get_tree().get_nodes_in_group("PlayerUnit"))
	GameEvents.restart_level.connect(on_restart_level)

func on_player_unit_destroyed():
	player_count -= 1
	if player_count == 0:
		game_over.visible = true
		get_tree().paused = true
		
func on_enemy_unit_destroyed():
	enemy_count -= 1
	if enemy_count == 0:
		ScreenTransition.transition_to_packed(next_level)
	
func on_level_start_timer_timeout():
	GameEvents.level_started.emit()
	
func on_restart_level():
	get_tree().reload_current_scene()
