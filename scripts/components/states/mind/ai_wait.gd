## Contributors: Richard Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	print("LOG: Entered WAIT AI state")
	actor.body_state.transition_to("Idle")
	
func physics_update(delta: float) -> void:
	pass
