## Contributors: Richard Johnson
extends State

func enter() -> void:
#	print("LOG: Entered ATTACK state")
	actor.play_animation("attack")
	start_attack()
	
func physics_update(delta: float) -> void:
	# 1. Allow continued horizontal movement/drift 
	var target_velocity_x = actor.direction * actor.walk_speed
	actor.velocity.x = lerp(actor.velocity.x, target_velocity_x, 16 * delta)
	
	# 2. Continue applying gravity if they are in the air
	if not actor.is_on_floor():
		if actor.velocity.y < 0:
			actor.velocity.y += actor.gravity * delta / 4.0
		else:
			actor.velocity.y += actor.gravity * delta / 2.0
	else:
		var fall_distance =  actor.global_position.y - actor.start_height
		
		if fall_distance > actor.land_stun_threashold:
			state_machine_manager.transition_to("Land")
			return
		
	# 3. Transition back once the attack is done
	# (Logic to check if animation finished)
	if not actor.sprite.is_playing() or actor.sprite.animation != "attack":
		if actor.direction == 0:
			state_machine_manager.transition_to("Idle")
			return
		
		if actor.is_on_floor():
			state_machine_manager.transition_to("Walk")
		elif actor.velocity.y < 0:
			state_machine_manager.transition_to("Jump")
		else:
			state_machine_manager.transition_to("Fall")

func start_attack():
	actor.hitbox.monitoring = true  # Turn it on
	
	# NEW: Manually check for bodies already overlapping
	var overlapping_areas = actor.hitbox.get_overlapping_areas()
	
	for area in overlapping_areas:
		# Manually call the same function the signal would call
		actor.hitbox._on_area_entered(area)
