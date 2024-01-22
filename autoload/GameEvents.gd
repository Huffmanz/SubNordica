extends Node

signal level_started
signal unit_selection_changed(unit: PlayerUnit)
signal add_screenshake(amount, duration)
signal enemy_move_request(unit: EnemyUnit, distance: float, target_location: Vector2)
signal camera_limits_changed(left, right, top, bottom)
signal player_unit_destroyed
signal enemy_unit_destroyed
signal game_over
signal restart_level
