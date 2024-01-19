class_name UnitOverlay
extends TileMap


func draw(cells: Array) -> void:
	clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		set_cell(0,cell,0, Vector2i(0,0))
