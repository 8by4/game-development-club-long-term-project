## Contributors: Richard Johnson
class_name State
extends Node

## Reference to the finite state machine manager
var state_machine_manager = null

## The CharacterBody2D (Player or Enemy) this state is controlling
var actor: Actor

## Virtual function called when entering the state
func enter() -> void:
	pass

## Virtual function called when exiting the state
func exit() -> void:
	pass

## Virtual function for frame-based updates (process)
func update(delta: float) -> void:
	pass

## Virtual function for physics-based updates (physics_process)
func physics_update(delta: float) -> void:
	pass

func print_debug_log(string: String) -> void:
	if OS.is_debug_build(): print("LOG: ", string)
