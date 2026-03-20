## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered FLY state")
	actor.play_animation("fly")
	update_flying_state()

func physics_update(delta: float) -> void:
	if update_flying_state(): return
	
	var speed = actor.get_movement_speed()
	var target_velocity: Vector2
	
	if actor.flying:
		if actor.is_ai() and actor.ai.has_valid_target():
			var target_pos = actor.ai.target.global_position + Vector2(0, actor.hover_height)
			var dir = target_pos - actor.global_position
			target_velocity = dir.normalized() * speed
		else:
			target_velocity = Vector2(actor.direction * speed, 0)
		
		if actor.flying_bobber:
			target_velocity.y += actor.effects.compute_bobbing(delta)
	else:
		target_velocity = Vector2(actor.direction * speed, 0)
	
	actor.velocity = actor.velocity.lerp(target_velocity, (16 * delta))

func update_flying_state() -> bool:
	actor.update_flying_state()
	
	if not actor.flying:
		transition_from_flying()
	
	return not actor.flying

func transition_from_flying():
	if not actor.is_on_floor():
		state_machine_manager.transition_to("Fall")
	elif actor.direction != 0:
		state_machine_manager.transition_to("Walk")
	else:
		state_machine_manager.transition_to("Idle")
