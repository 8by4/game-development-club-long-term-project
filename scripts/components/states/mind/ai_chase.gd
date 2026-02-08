## Contributors: Richard Johnson
extends State

func enter() -> void:
	print("LOG: Entered CHASE AI state")
	actor.body_state.transition_to("Walk")
	
func physics_update(delta: float) -> void:
#	var player = get_tree().get_first_node_in_group("player")
	# Simple AI: Walk toward player if seen, else 0
	var player = actor.target
	
	if player and actor.player_in_range:
		var distance = actor.global_position.distance_to(player.global_position)
		var d = player.global_position.x - actor.global_position.x
		var delta_x = abs(d)
		var delta_y = abs(actor.global_position.y - player.global_position.y)
		var jump_height = abs(actor.jump_height)
		
		if distance <= actor.attack_range:
			actor.body_state.transition_to("Attack")
		
		# Set the 'intent' variable for the FSM to read
		if delta_x > actor.deadzone:
			actor.direction = sign(d)
		else:
			actor.direction = 0
		
		# Allow the AI to do basic jumps.
		# Navigation will require 'smart' jumping.
		if delta_y > jump_height / 10.0 and delta_y < jump_height:
			actor.jump_queued = true
			actor.body_state.transition_to("Jump")
	else:
		# Stop moving if the player is gone
		state_machine_manager.transition_to("Wait")
