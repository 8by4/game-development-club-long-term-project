## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	if actor.is_player(): return
	print("LOG: Entered WAIT AI state")
	
	if actor.is_attacking():
		await actor.sprite.animation_finished
	
	actor.body.transition_to("Idle")

func physics_update(_delta: float) -> void:
	pass
