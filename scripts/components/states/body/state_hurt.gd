## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered HURT state")
	actor.play_animation("hurt")
	
	if actor.indestructible:
		actor.effects.chrome_glow()
	else:
		# Start blinking for 1.5 seconds every 0.1 seconds
		actor.effects.blink(1.5, 0.1)
	
	# Apply Knockback
	if actor.knockback_enabled:
		var f = actor.knockback_force * actor.knockback_scale
		var x = f.x * actor.knockback_direction
		var v = Vector2(x, f.y)
		
		if actor.indestructible:
			actor.velocity = v / 8.0
		else:
			actor.velocity = v
	
	if actor.fly_always:
		actor.gravity = 512
	actor.flying = false
	
	# Reset timer
	actor.stun_timer = actor.stun_duration

func physics_update(delta: float) -> void:
	# Apply Gravity while in hit-stun
	actor.velocity.y += actor.gravity * delta 
	
	if actor.collapsed:
		if actor.is_on_floor() or actor.fly_always:
			if actor.get_animation_progress() > 0.2:
				state_machine_manager.transition_to("Collapse")
			return
	
	# Handle Stun Timer
	actor.stun_timer -= delta
	if actor.stun_timer <= 0:
		if actor.is_on_floor():
			state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Fall")

func exit():
	if actor.fly_always:
		if actor.collapsed:
			actor.gravity = 128
		else:
			actor.gravity = 0
			actor.flying = true
