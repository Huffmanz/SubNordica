class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grid: Grid = preload("res://resources/grid_32.tres")
@export var tilemap: TileMap
@onready var _unit_path: UnitPath = $UnitPath
@onready var cursor: Cursor = $Cursor
@onready var _unit_overlay = $UnitOverlay
@onready var random_audio_player = $RandomAudioPlayer


#key: cell value: unit
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

func _ready() -> void:
	_reinitialize()
	cursor.accept_pressed.connect(on_cursor_accept_pressed)
	cursor.moved.connect(on_cursor_moved)
	GameEvents.enemy_move_request.connect(on_enemy_move_request)
	
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()

func on_cursor_accept_pressed(cell: Vector2):
	if not _active_unit:
		_select_unit(cell)
	#if clicking on a unit that is not the active unit
	elif _units.has(cell) and _units[cell] is Unit and _units[cell] != _active_unit:
		_deselect_active_unit()
		_clear_active_unit()
		_select_unit(cell)
	elif _active_unit.is_selected and _active_unit is PlayerUnit:
		_move_active_unit(cell)

func on_cursor_moved(new_cell: Vector2):
	if _active_unit == null: return
	if not _active_unit is PlayerUnit: return
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)

func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false

func _reinitialize() -> void:
	_units.clear()
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			var tile_pos = Vector2i(x + tilemap.get_used_rect().position.x , y + tilemap.get_used_rect().position.y)
			var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
			if tile_data == null or !tile_data.get_custom_data("walkable"):
				var tile_global_pos := to_global(tilemap.map_to_local(tile_pos))
				var cell = grid.calculate_grid_coordinates(tile_global_pos)
				_units[cell] = null
		
	
	# loop over the node's children and filter them to find the units. 
	# may want to use the node group feature instead to place your units
	# anywhere in the scene tree.
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit

func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:

	var array := []
	var stack := [cell]

	while not stack.is_empty():
		var current = stack.pop_back()
		# For each cell, we ensure that we can fill further.
		#
		# The conditions are:
		# 1. We didn't go past the grid's limits.
		# 2. We haven't already visited and filled this cell
		# 3. We are within the `max_distance`, a number of cells.
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		# This is where we check for the distance between the starting `cell` and the `current` one.
		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			stack.append(coordinates)
	return array

func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	if !_units[cell]: return
	random_audio_player.play_random()
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_active_unit.range_updated.connect(_active_unit_range_updated)
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

func _deselect_active_unit() -> void:
	if _active_unit == null: return
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()
	_active_unit.range_updated.disconnect(_active_unit_range_updated)

func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

func _active_unit_range_updated():
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return

	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit

	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	
	#uncomment below to only issue 1 command at a time
	#await _active_unit.walk_finished
	_clear_active_unit()
	
func _move_unit(unit: Unit, walkable_cells, new_cell: Vector2) -> void:
	var _pathfinder: PathFinder= PathFinder.new(grid, walkable_cells)
	if is_occupied(new_cell):
		return
	_units.erase(unit.cell)
	_units[new_cell] = unit
	unit.walk_along(_pathfinder.calculate_point_path(unit.cell, new_cell))
	
func on_enemy_move_request(enemy: EnemyUnit, distance: float, target_location: Vector2):
	if enemy._is_walking: return
	var walkable_cells: Array= get_walkable_cells(enemy)
	var in_range_cells = walkable_cells.filter(func(a: Vector2):
			var world_pos = grid.calculate_map_position(a)
			return world_pos.distance_squared_to(target_location) < pow(distance, 2)
	)
	if len(in_range_cells) == 0:
		return
		
	in_range_cells.sort_custom(func(a: Vector2, b: Vector2):
			var world_pos_a = grid.calculate_map_position(a)
			var world_pos_b = grid.calculate_map_position(b)
			var a_distance = world_pos_a.distance_squared_to(enemy.global_position)
			var b_distance = world_pos_b.distance_squared_to(enemy.global_position)
			return a_distance < b_distance 
	)
	
	_move_unit(enemy, walkable_cells, in_range_cells[0])
