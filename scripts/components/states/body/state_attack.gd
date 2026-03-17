## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
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
	
	if actor.deflected and not actor.repelled:
		var current_anim = actor.sprite.animation
		var total_frames = actor.sprite.sprite_frames.get_frame_count(current_anim)
	
		if actor.sprite.frame >= (total_frames / 2.5):
			actor.repelled = true
			bounce_attack()
	
	# 1. Allow continued horizontal movement/drift 
	if not actor.attack_stationary:
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

func bounce_attack():
	# 1. Capture the frame where the hit occurred
	var impact_frame = actor.sprite.frame
	
	# 2. Freeze the animation (Hitstop)
	actor.sprite.pause() 
	
	# 3. Micro-delay to sell the impact 
	# This 'sticks' the weapon to the indestructible enemy for a moment
	await get_tree().create_timer(0.08).timeout
	
	# 4. Reverse the animation
	# Setting a negative speed_scale plays the current animation backward
	actor.sprite.speed_scale = -1.5 
	actor.sprite.play() 
	
	# 5. Clean up: Stop reversing once we reach the start
	# We can use a signal to reset the speed for the next normal attack
	if not actor.sprite.animation_finished.is_connected(_on_bounce_finished):
		actor.sprite.animation_finished.connect(_on_bounce_finished, CONNECT_ONE_SHOT)

func _on_bounce_finished():
	actor.sprite.stop()
	actor.sprite.speed_scale = 1.0 # Reset to forward play
	transition_after_attack()

func transition_after_attack():
	actor.set_attack_cooldown()
	actor.hitbox.monitoring = false
	actor.deflected = false
	actor.repelled = false
	
	if actor.ai and actor.no_more_target():
		actor.disengage_target()
		return
	
	if actor.direction == 0 or not actor.move_enabled:
		if actor.velocity.y > 0:
			state_machine_manager.transition_to("Fall")
		else:
			state_machine_manager.transition_to("Idle")
		return
	
	if actor.is_on_floor():
		state_machine_manager.transition_to("Walk")
	elif actor.velocity.y < 0:
		state_machine_manager.transition_to("Jump")
	else:
		state_machine_manager.transition_to("Fall")
