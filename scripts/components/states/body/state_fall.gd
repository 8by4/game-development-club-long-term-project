## Contributors: Richard Johnson
extends State

func enter() -> void:
	print_debug_log("Entered FALL state")
	actor.start_height = actor.global_position.y
	actor.play_animation("fall")

func physics_update(delta: float) -> void:
	# 1. Horizontal Movement (Keep momentum)
	var target_velocity_x = actor.direction * actor.walk_speed
	actor.velocity.x = lerp(actor.velocity.x, target_velocity_x, 16 * delta)
	
	# 2. Apply Gravity
	actor.velocity.y += actor.gravity * delta / 2.0
	actor.jump_queued = false
	
	# 3. THE TRANSITION: Look for the floor
	if actor.is_on_floor():
		var fall_distance =  actor.global_position.y - actor.start_height
		if fall_distance > actor.land_stun_threashold:
			state_machine_manager.transition_to("Land")
			return
		
		# This fixes the walk animation when the 
		# entity is already moving horizontally.
		actor.velocity = Vector2.ZERO

		if actor.direction == 0:
			state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Walk")
