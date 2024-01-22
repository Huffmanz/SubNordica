extends CanvasLayer

@export var first_level: PackedScene
@onready var play_button = %PlayButton


func _ready():
	play_button.pressed.connect(on_play_button_pressed)
	
func on_play_button_pressed():
	$AudioStreamPlayer.playing = false
	ScreenTransition.transition_to_packed(first_level)
