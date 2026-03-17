## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	print("LOG: Entered PATROL AI state")
#	actor.body.transition_to("Walk")

func physics_update(delta: float) -> void:
	pass
