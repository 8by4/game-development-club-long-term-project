## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
extends State

func enter() -> void:
	if actor.collapsed: return
	if actor.is_player(): return
	print("LOG: Entered CHASE AI state")
	
	actor.update_flying_state()
	
	if actor.move_enabled:
		if actor.flying:
			actor.body.transition_to("Fly")
		else:
			actor.body.transition_to("Walk")
	else:
		actor.body.transition_to("Idle")

func physics_update(_delta: float) -> void:
	if actor.collapsed: return
	if actor.is_player(): return
	
	if actor.suicidal and actor.is_primed:
		return
	
	if actor.target and actor.player_in_range:
		actor.update_facing_state()
		
		if not handle_attack_logic():
			handle_jump_logic()
	elif actor.patrol_enabled:
		state_machine_manager.transition_to("Patrol")
	else:
		# Stop moving if the player is gone
		state_machine_manager.transition_to("Wait")

func handle_attack_logic() -> bool:
	if not actor.can_attack_again(): return false
	if not actor.is_facing_target(): return false
	
	var distance = actor.ai.get_distance_to_target()
	
	if actor.flying:
		if distance <= actor.swoop_range:
			actor.body.transition_to("Swoop_Attack")
			return true
	elif distance <= actor.attack_range:
		actor.body.transition_to("Attack")
		return true
	
	return false

func handle_jump_logic():
	if not actor.jump_enabled: return
	if actor.attack_stationary and actor.body.is_state("Attack"):
		return
		
	var player = actor.target
	var diff_y = actor.global_position.y - player.global_position.y
	var jump_height = abs(actor.jump_height)
	
	# Allow the AI to do basic jumps.
	# Navigation will require 'smart' jumping.
	if diff_y > jump_height / 10.0 and diff_y < jump_height:
		actor.jump_queued = true
		actor.body.transition_to("Jump")
