## Contributors: Richard Johnson
extends State

func enter() -> void:
	print_debug_log("Entered LAND (STUN) state")
	actor.play_animation("stunned")
	
	# Start blinking for 1.5 seconds every 0.1 seconds
	actor.blink(1.5, 0.1)
	
	# Optionally reduce velocity to simulate impact
#	actor.velocity.x *= 0.1
	actor.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	# Allow gravity just in case of ledges
	if not actor.is_on_floor():
		state_machine_manager.transition_to("Fall") 
		return
		
	# Transition to Idle or Walk once the landing animation finishes
	if actor.animation_is_finished("stunned"):
		# This fixes the walk animation when the 
		# entity is already moving horizontally.
		actor.velocity = Vector2.ZERO
		
		if actor.direction == 0:
			state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Walk")
