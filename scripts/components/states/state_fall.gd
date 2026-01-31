extends State

func enter() -> void:
	print("LOG: Entered FALL state")
	actor.play_animation("jump")

func physics_update(delta: float) -> void:
	# 1. Horizontal Movement (Keep momentum)
	var target_velocity_x = actor.direction * actor.walk_speed
	actor.velocity.x = lerp(actor.velocity.x, target_velocity_x, 16 * delta)
	
	# 2. Apply Gravity
	actor.velocity.y += actor.gravity * delta / 3.0
	
	# 3. THE TRANSITION: Look for the floor
	if actor.is_on_floor():
		if actor.direction == 0:
			state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Walk")
