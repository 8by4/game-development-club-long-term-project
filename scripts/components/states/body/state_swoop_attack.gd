## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered SWOOP ATTACK state")
	actor.play_animation("fly")

func physics_update(delta: float) -> void:
	var target_velocity : Vector2 = Vector2(
		actor.direction * actor.walk_speed, 0)
		
	actor.velocity = actor.velocity.lerp(target_velocity, (16 * delta))
	
	if actor.direction == 0:
		actor.velocity.x = 0
		state_machine_manager.transition_to("Idle")
