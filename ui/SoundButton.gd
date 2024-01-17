extends Button

@onready var random_audio_stream_player = $RandomAudioStreamPlayer

func _ready():
	pressed.connect(on_pressed)
	
func on_pressed():
	random_audio_stream_player.play_random()

