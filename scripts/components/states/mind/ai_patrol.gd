## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	if actor.is_player(): return
	print("LOG: Entered PATROL AI state")
	
	actor.update_flying_state()
	
	if actor.flying:
		actor.body.transition_to("Fly")
	else:
		actor.body.transition_to("Walk")

func physics_update(delta: float) -> void:
	if actor.collapsed: return
	if actor.is_player(): return
	## I plan on using the navigation system to patrol an area.
