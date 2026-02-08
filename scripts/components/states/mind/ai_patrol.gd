## Contributors: Richard Johnson
extends State

func enter() -> void:
	print("LOG: Entered PATROL AI state")
	actor.body_state.transition_to("Walk")

func physics_update(delta: float) -> void:
	pass
