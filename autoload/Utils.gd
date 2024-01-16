extends Node

func instantiate_scene_on_world(scene: PackedScene, position: Vector2):
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	return instance
