## Contributors: Richard Johnson
class_name StateMachineManager
extends Node

## The initial state to start with on ready
@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			# This line saves the node by its lowercase name
			states[child.name.to_lower()] = child
			child.state_machine_manager = self
			child.actor = get_parent()
			print("Registered state: ", child.name.to_lower()) # DEBUG PRINT
			
	# Set and enter the initial state
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _process(delta: float) -> void:
	update(delta)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	physics_update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Handles transitioning to a new state by name
func transition_to(state_name: String) -> void:
	var new_state = states.get(state_name.to_lower())
	
	if not new_state:
		printerr("[StateMachine] State ", state_name, " not found!")
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state

func get_state() -> String:
	return current_state.name.to_lower();

func is_state(state: String) -> bool:
	return state.to_lower() == get_state()

func not_state(state: String) -> bool:
	return state.to_lower() != get_state()
