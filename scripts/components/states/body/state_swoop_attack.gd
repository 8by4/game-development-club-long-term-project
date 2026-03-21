## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered SWOOP ATTACK state")
	actor.update_flying_state()
	
	if not actor.flying:
		state_machine_manager.transition_to("Attack")
		return
	
	actor.play_animation("swoop_attack")
	
	if actor.hitbox_variable:
		actor.reset_hitbox_width()

func physics_update(delta: float) -> void:
	if actor.suicidal and actor.is_primed: return
	if state_machine_manager.not_state("Swoop_Attack"): return
	
	var progress = actor.get_animation_progress()
	
	if actor.suicidal and progress > actor.damage_begin_threshold:
		state_machine_manager.transition_to("Critical")
		return
	
	# Begin hitbox monitoring after a threshold of progress in the attack
	if not actor.hitbox.monitoring and not actor.suicidal:
		if progress > actor.damage_begin_threshold:
			actor.hitbox.monitoring = true
			actor.hitbox.enter_attack_window()
	
	# Update the hitbox over the attack
	if actor.hitbox_variable:
		actor.update_hitbox_width()
	
	var target_velocity: Vector2
	
	if actor.is_ai() and actor.ai.has_valid_target():
		target_velocity = calculate_swoop_velocity(progress)
	else:
		# Fallback if target is lost mid-swoop
		target_velocity = Vector2(actor.direction * actor.get_movement_speed(), 0)
	
	actor.velocity = actor.velocity.lerp(target_velocity, 10 * delta)
	
	if actor.animation_is_finished("swoop_attack"):
		transition_after_swoop_attack()

func calculate_swoop_velocity(progress: float) -> Vector2:
	var target_pos = get_predicted_target_pos(actor.look_ahead)
	var current_pos = actor.global_position
	
	# 1. Calculate the height difference
	# We only care if we are ABOVE the player (positive value)
	var height_diff = max(0, target_pos.y - current_pos.y)
	
	# 2. Create a dampening weight (0.0 to 1.0)
	# If height_diff is 200+, weight is 1.0. If height_diff is 0, weight is 0.
	var swoop_threshold = 100.0 
	var dampening = clamp(height_diff / swoop_threshold, 0.0, 1.0)
	
	# 3. Determine the "Arc" using a Sine wave or Custom Curve
	# We want the Y-velocity to go DOWN then UP
	# Apply dampening to the vertical dip
	var swoop_intensity = 200.0 # How deep the dive is
	var vertical_dip = sin(progress * PI) * (swoop_intensity * dampening)
	
	# 4. Combine: Move forward but add a vertical "dip" based on progress
	# This creates a U-shape relative to the flight path
	var dir_to_target = (target_pos - current_pos).normalized()
	var horizontal_vel = dir_to_target * actor.get_movement_speed() * 1.5
	var vertical_vel = Vector2.DOWN * (cos(progress * PI) * vertical_dip)
	
	# Return the horizontal move + the dampened vertical dip
	return horizontal_vel + vertical_vel
#	return horizontal_vel + (Vector2.DOWN * vertical_dip)

func get_predicted_target_pos(look_ahead_seconds: float) -> Vector2:
	var target = actor.ai.target
	var target_vel = target.velocity
	
	return target.global_position + (target_vel * look_ahead_seconds)

func transition_after_swoop_attack():
	if actor.is_ai() and actor.no_valid_target():
		actor.disengage_target()
		return
	
	if actor.direction != 0:
		state_machine_manager.transition_to("Fly")
	else:
		state_machine_manager.transition_to("Idle")

func exit() -> void:
	actor.set_attack_cooldown()
	actor.hitbox.monitoring = false
	actor.attack_effect_spawned = false
