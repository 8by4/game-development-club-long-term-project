## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered IDLE state")
	actor.direction = 0
	actor.velocity.x = 0
	actor.update_flying_state()
	actor.play_animation("idle")

func physics_update(delta: float) -> void:
	if actor.flying and actor.flying_bobber:
		actor.apply_bobbing(delta, 0.0)
		
	if not actor.flying and not actor.is_on_floor():
		actor.coyote_time = 0.0
		state_machine_manager.transition_to("Fall")
		return
	
	# Logic: If there is horizontal input, start walking
	if actor.direction != 0 and actor.move_enabled:
		if actor.flying:
			state_machine_manager.transition_to("Fly")
		else:
			state_machine_manager.transition_to("Walk")
		return
	
	# Logic: If jump is pressed, jump
	if actor.jump_queued and actor.is_on_floor():
		actor.coyote_time = 0.0
		state_machine_manager.transition_to("Jump")
		return
	
	actor.velocity.x = 0
