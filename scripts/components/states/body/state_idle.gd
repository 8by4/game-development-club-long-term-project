## Contributors: Richard Johnson
extends State

func enter() -> void:
	print_debug_log("Entered IDLE state")
	actor.play_animation("idle")
	actor.direction = 0
	actor.velocity.x = 0

func physics_update(delta: float) -> void:
	if not actor.is_on_floor():
		state_machine_manager.transition_to("Fall")
		return
		
	# Logic: If there is horizontal input, start walking
	if actor.direction != 0:
		state_machine_manager.transition_to("Walk")
		return
	
	# Logic: If jump is pressed, jump
	if actor.jump_queued and actor.is_on_floor():
		state_machine_manager.transition_to("Jump")
		return
		
	actor.velocity.x = 0
