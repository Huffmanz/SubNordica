extends Camera2D

@onready var timer = $Timer
@export var camera_speed = 400
@export var zoom_speed = 1
@export var zoom_in_limit = 3.0
@export var zoom_out_limit = .75

var shake = 0.0

func _ready():
	GameEvents.add_screenshake.connect(start_screenshake)
	timer.timeout.connect(on_timer_timeout)
	GameEvents.camera_limits_changed.connect(on_camera_limits_changed)
	
func _process(delta):
	var direction_x = Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
	var direction_y = Input.get_action_raw_strength("move_down") - Input.get_action_raw_strength("move_up")
	var movement = Vector2(direction_x, direction_y)
	offset.x = randf_range(-shake, shake)
	offset.y = randf_range(-shake, shake)
	if Input.is_action_just_pressed("zoom_in"):
		zoom.x += zoom.x * zoom_speed * delta
		zoom.y += zoom.y  * zoom_speed * delta
	
	if Input.is_action_just_pressed("zoom_out"):
		zoom.x -= zoom.x * zoom_speed * delta
		zoom.y -= zoom.y  * zoom_speed * delta
		
	zoom.x = clampf(zoom.x, zoom_out_limit, zoom_in_limit)
	zoom.y = clampf(zoom.y, zoom_out_limit, zoom_in_limit)
	position += movement * camera_speed * delta
	position = Vector2(clamp(position.x,limit_left+get_viewport_rect().size.x/2,limit_right-get_viewport_rect().size.x/2),clamp(position.y,limit_top+get_viewport_rect().size.y/2,limit_bottom-get_viewport_rect().size.y/2))

func start_screenshake(amount, duration):
	shake = amount
	timer.start(duration)
	
func on_timer_timeout():
	shake = 0.0

func on_camera_limits_changed(left, right, top, bottom):
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = bottom
