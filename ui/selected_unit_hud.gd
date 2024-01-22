extends CanvasLayer

@onready var add_range_button = %AddRangeButton
@onready var subtract_range_button = %SubtractRangeButton
@onready var max_range_label = %MaxRangeLabel
@onready var add_attack_button = %AddAttackButton
@onready var attack_label = %AttackLabel
@onready var subtract_attack_button = %SubtractAttackButton
@onready var add_heal_button = %AddHealButton
@onready var heal_label = %HealLabel
@onready var subtract_heal_button = %SubtractHealButton
@onready var reset_crew = %ResetCrew
@onready var crew_label = %CrewLabel

var selected_unit: PlayerUnit

func _ready():
	visible = false
	GameEvents.unit_selection_changed.connect(on_selected_unit_changed)
	add_range_button.pressed.connect(on_add_range_pressed)
	subtract_range_button.pressed.connect(on_subtract_range_pressed)
	add_attack_button.pressed.connect(on_add_attack_button_pressed)
	subtract_attack_button.pressed.connect(on_subtract_attack_button_pressed)
	add_heal_button.pressed.connect(on_add_heal_button_pressed)
	subtract_heal_button.pressed.connect(on_subtract_heal_button_pressed)
	reset_crew.pressed.connect(on_reset_crew_pressed)
	
func on_selected_unit_changed(unit: PlayerUnit):
	if not unit:
		if selected_unit != null:
			selected_unit.range_updated.disconnect(on_unit_range_updated)
			selected_unit.attack_range_updated.disconnect(on_attack_range_updated)
			selected_unit.heal_percent_updated.disconnect(on_heal_percent_updated)
			selected_unit.health_component.died.disconnect(on_died)
			selected_unit = null
		visible = false
		return
	selected_unit = unit
	selected_unit.range_updated.connect(on_unit_range_updated)
	selected_unit.attack_range_updated.connect(on_attack_range_updated)
	selected_unit.heal_percent_updated.connect(on_heal_percent_updated)
	selected_unit.health_component.died.connect(on_died)
	visible = true
	updated_crew()
	
func on_died():
	selected_unit = null
	visible = false
		
func on_add_range_pressed():
	if not selected_unit: return
	selected_unit.change_move_range(1)
	
func on_subtract_range_pressed():
	selected_unit.change_move_range(-1)
	
func on_unit_range_updated():
	updated_crew()
	
func on_attack_range_updated(_new_range: float):
	updated_crew()
	
func on_heal_percent_updated(_heal_percent: float):
	updated_crew()
	
func on_add_attack_button_pressed():
	selected_unit.change_attack_range(1)
	
func on_subtract_attack_button_pressed():
	selected_unit.change_attack_range(-1)
	
func on_add_heal_button_pressed():
	selected_unit.change_heal_crew(1)
	
func on_subtract_heal_button_pressed():
	selected_unit.change_heal_crew(-1)
	
func on_reset_crew_pressed():
	selected_unit.change_move_range(-selected_unit.crew_assigned_movement)
	selected_unit.change_attack_range(-selected_unit.crew_assigned_attack)
	selected_unit.change_heal_crew(-selected_unit.crew_assigned_heal)
	
func updated_crew():
	heal_label.text = str(selected_unit.crew_assigned_heal) 
	attack_label.text = str(selected_unit.crew_assigned_attack) 
	max_range_label.text = str(selected_unit.crew_assigned_movement) 
	crew_label.text = str(selected_unit.crew_unassigned) + " / " + str(selected_unit.crew)
