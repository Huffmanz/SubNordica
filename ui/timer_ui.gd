extends CanvasLayer

@export var timer: Timer
@onready var time_label = %time_label

func _ready():
	timer.timeout.connect(on_timer_timeout)

func _process(_delta):
	if timer == null:
		return
	time_label.text = format_seconds_to_string(timer.time_left)

func on_timer_timeout():
	visible = false

func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
