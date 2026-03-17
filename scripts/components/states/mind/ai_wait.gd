## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	print("LOG: Entered WAIT AI state")
	
	if actor.body.is_state("Attack"):
		await actor.sprite.animation_finished
		
	actor.body.transition_to("Idle")
	
func physics_update(delta: float) -> void:
	pass
