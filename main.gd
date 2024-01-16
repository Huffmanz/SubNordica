extends Node2D

@export var level_start_timer: Timer

func _ready():
	level_start_timer.timeout.connect(on_level_start_timer_timeout)

func on_level_start_timer_timeout():
	GameEvents.level_started.emit()
