## Contributors: Richard Johnson
extends State

func enter() -> void:
	print("LOG: Entered CHASE AI state")
	
	if actor.move_enabled:
		actor.body.transition_to("Walk")
	else:
		actor.body.transition_to("Idle")

func physics_update(_delta: float) -> void:
#	var player = get_tree().get_first_node_in_group("player")
	# Simple AI: Walk toward player if seen, else 0
	var player = actor.target
	
#	if player and player.collapsed:
#		actor.disengage_target()
#		actor.body.transition_to("Idle")
#		actor.mind.transition_to("Wait")
	if player and actor.player_in_range:
		var d = player.global_position.x - actor.global_position.x
		var delta_x = abs(d)
		var delta_y = actor.global_position.y - player.global_position.y
		var jump_height = abs(actor.jump_height)
		
		if actor.can_attack_again():
			var distance = actor.global_position.distance_to(player.global_position)
			if distance <= actor.attack_range:
				actor.body.transition_to("Attack")
		
		# Set the 'intent' variable for the FSM to read
		if actor.turning_enabled:
			if delta_x > actor.deadzone:
				actor.direction = sign(d)
			else:
				actor.direction = 0
		
		if actor.attack_stationary and actor.body.is_state("attack"):
			pass
		elif actor.jump_enabled:
			# Allow the AI to do basic jumps.
			# Navigation will require 'smart' jumping.
			if delta_y > jump_height / 10.0 and delta_y < jump_height:
				actor.jump_queued = true
				actor.body.transition_to("Jump")
	elif actor.patrol_enabled:
		state_machine_manager.transition_to("Patrol")
	else:
		# Stop moving if the player is gone
		state_machine_manager.transition_to("Wait")
