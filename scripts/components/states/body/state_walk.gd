## Contributors: Richard Johnson
extends State

func enter() -> void:
	print("LOG: Entered WALK state")
	actor.play_animation("walk")

func physics_update(delta: float) -> void:
	var target_velocity : Vector2 = Vector2(
		actor.direction * actor.walk_speed, 0)
		
	if actor.is_on_floor():
		actor.velocity = actor.velocity.lerp(target_velocity, (16 * delta))
		if actor.direction == 0:
			actor.velocity.x = 0
			
	if actor.jump_queued and actor.velocity.y >= 0:
		state_machine_manager.transition_to("Jump")
		return
		
	if actor.velocity.y > 0 or not actor.is_on_floor():
		state_machine_manager.transition_to("Fall")
		return
		
	if actor.direction == 0:
		state_machine_manager.transition_to("Idle")
		return
