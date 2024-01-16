class_name PlayerUnit
extends Unit

func on_subtract_range_pressed():
	move_range -= 1
	
func on_add_range_pressed():
	move_range += 1
	
func set_is_selected(value):
	super.set_is_selected(value)
	if is_selected:
		GameEvents.unit_selection_changed.emit(self)
	else:
		GameEvents.unit_selection_changed.emit(null)
	

