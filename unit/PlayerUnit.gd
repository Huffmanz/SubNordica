class_name PlayerUnit
extends Unit

@onready var animated_sprite_2d = $Visuals/AnimatedSprite2D

func _ready():
	super._ready()
	walk_started.connect(on_walk_started)
	walk_finished.connect(on_walk_finished)
		
func on_walk_started():
	animated_sprite_2d.play("move")

func on_walk_finished():
	animated_sprite_2d.play("default")

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

func on_died():
		GameEvents.player_unit_destroyed.emit()
		GameEvents.add_screenshake.emit(1.0, .25)
		super.on_died()

