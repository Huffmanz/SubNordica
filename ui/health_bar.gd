extends ProgressBar

@export var health_component: HealthComponent

func _ready():
	health_component.health_changed.connect(on_health_changed)
	value = health_component.get_health_percent()

func on_health_changed():
	value = health_component.get_health_percent()
