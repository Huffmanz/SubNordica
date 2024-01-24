extends CanvasLayer

@onready var main_menu = %MainMenu
@onready var restart = %Restart
@onready var game_over_player = $GameOverPlayer

var main_menu_scene = preload("res://levels/main_menu.tscn")

func _ready():
	restart.pressed.connect(on_restart_pressed)
	main_menu.pressed.connect(on_main_menu_pressed)
	visibility_changed.connect(on_visibility_changed)
	
func on_restart_pressed():
	get_tree().paused = false
	GameEvents.restart_level.emit()
	
func on_main_menu_pressed():
	ScreenTransition.transition_to_packed(main_menu_scene)
	
func on_visibility_changed():
	if visible:
		game_over_player.play()

