extends Node

signal level_started
signal unit_selection_changed(unit: PlayerUnit)
signal add_screenshake(amount, duration)
signal enemy_move_request(unit: EnemyUnit, distance: float, target_location: Vector2)
