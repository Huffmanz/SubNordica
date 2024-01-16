class_name  AquireTargetComponent
extends Node2D

@export var target_layer: Array[String]
@export var should_lead_shot: bool = true
@export var target_closest: bool = true
var current_target

func acquire_target(max_range: float) -> Vector2:
	var targets : Array[Node]
	for i in target_layer:
		targets += get_tree().get_nodes_in_group(i)

	targets = targets.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(global_position) < pow(max_range, 2)
	)
	if targets.size() == 0:
		return Vector2.ZERO
	if targets.size() == 1:
		current_target = targets[0]
		if should_lead_shot:
			return lead_shot()
		else:
			return current_target.global_position
			
	if target_closest:
		targets.sort_custom(func(a: Node2D, b: Node2D):
			var a_distance = a.global_position.distance_squared_to(global_position)
			var b_distance = b.global_position.distance_squared_to(global_position)
			return a_distance < b_distance
		)
	else:
		targets.sort_custom(func(a: Node2D, b: Node2D):
			var a_distance = a.global_position.distance_squared_to(global_position)
			var b_distance = b.global_position.distance_squared_to(global_position)
			return a_distance > b_distance
		)
	current_target = targets[0]
	if should_lead_shot:
		return lead_shot()
	else:
		return current_target.global_position
			
func lead_shot() -> Vector2:
	if current_target as CharacterBody2D:
		var Pti = current_target.global_transform.origin
		var Pbi = global_transform.origin
		var D = Pti.distance_to(Pbi)
		var Vt = current_target.get_velocity()
		var St = Vt.length()
		var Sb = 45
		var cos_theta = Pti.direction_to(Pbi).dot(Vt.normalized())
		var q_root = sqrt(2*D*St*cos_theta + 4*(Sb*Sb - St*St)*D*D )
		var q_sub = (2*(Sb*Sb - St*St))
		var q_left = -2*D*St*cos_theta
		var t1 = (q_left + q_root) / q_sub
		var t2 = (q_left - q_root) / q_sub
		
		var t = min(t1, t2)
		if t < 0:
			t = max(t1, t2)
		if t < 0 || is_nan(t):
			return current_target.global_position # can't hit, target too fast
		return Vt * t + Pti
	return current_target.global_position
