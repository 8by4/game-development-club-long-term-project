## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	print_debug_log("Entered CRITICAL state")
	actor.play_animation("critical")
	start_fuse()

func physics_update(_delta: float) -> void:
	actor.velocity = Vector2.ZERO

func start_fuse() -> void:
	actor.is_primed = true
	await actor.get_tree().create_timer(actor.fuse_time).timeout
	
	# Use a direct call to verify if the logic works without the state machine interrupting
	execute_explosion_logic()

func execute_explosion_logic() -> void:
	actor.hitbox.monitoring = true
	actor.hitbox_shape.shape.size = Vector2(actor.explosion_radius * 2.0, actor.explosion_radius * 2.0)
	
	# Force the engine to process the new shape immediately
#	await actor.get_tree().physics_frame
#	await actor.get_tree().physics_frame
	
	actor.hitbox.enter_attack_window()
	actor.effects.spawn_explosion(actor.global_position, actor.explosion_radius)
	
	await actor.get_tree().create_timer(0.3).timeout
	state_machine_manager.transition_to("Collapse")

func exit() -> void:
	actor.collapsed = true
	actor.hitbox.monitoring = false
