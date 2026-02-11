## Contributors: Richard Johnson
extends State

func enter() -> void:
	print_debug_log("Entered ATTACK state")
	actor.play_animation("attack")
	actor.hitbox.monitoring = true
	actor.hitbox.enter_attack_window()
	if actor.hitbox_variable:
		actor.reset_hitbox_width()

func physics_update(delta: float) -> void:
	if actor.hitbox_variable:
		actor.update_hitbox_width()
	
	# 1. Allow continued horizontal movement/drift 
	if actor.attack_stationary == false:
		var target_velocity_x = actor.direction * actor.walk_speed
		actor.velocity.x = lerp(actor.velocity.x, target_velocity_x, 16 * delta)
	else:
		actor.velocity.x = 0.0
	
	# 2. Continue applying gravity if they are in the air
	if not actor.is_on_floor():
		if actor.velocity.y < 0:
			actor.velocity.y += actor.gravity * delta / 4.0
		else:
			actor.velocity.y += actor.gravity * delta / 2.0
	else:
		var fall_distance =  actor.global_position.y - actor.start_height
		
		# Hard land which will leave the actor stunned
		if fall_distance > actor.land_stun_threashold:
			state_machine_manager.transition_to("Land")
			return
			
	# 3. Transition back once the attack is done
	if actor.animation_is_finished("attack"):
		transition_after_attack()
		return

func transition_after_attack():
	actor.hitbox.monitoring = false
	
	if actor.direction == 0:
		state_machine_manager.transition_to("Idle")
		return
	
	if actor.is_on_floor():
		state_machine_manager.transition_to("Walk")
	elif actor.velocity.y < 0:
		state_machine_manager.transition_to("Jump")
	else:
		state_machine_manager.transition_to("Fall")
