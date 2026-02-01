## Contributors: Richard Johnson

extends State

func enter() -> void:
	print("LOG: Entered JUMP state")
	actor.play_animation("jump")

func physics_update(delta: float) -> void:
	# 1. Handle Horizontal Movement (Air Control)
	# We use a lower lerp value in the air (e.g., 4) so it feels less 'snappy' than the ground
	var target_velocity_x = actor.direction * actor.walk_speed
	actor.velocity.x = lerp(actor.velocity.x, target_velocity_x, 16 * delta)
	
	# 2. Initiate Jump or Apply Gravity
	if actor.jump_queued and actor.is_on_floor():
		actor.velocity.y = -actor.jump_height * delta * 24
	else:
		actor.velocity.y += actor.gravity * delta / 4.0
		
	actor.jump_queued = false
	
	# 3. THE TRANSITION: If Y velocity is positive, we are falling
	if actor.velocity.y > 0:
		state_machine_manager.transition_to("Fall")
		return
		
	# 4. Emergency Ground Check (in case they jump into a low ceiling/platform)
	if actor.is_on_floor() and actor.velocity.y >= 0:
		state_machine_manager.transition_to("Idle")
		return
