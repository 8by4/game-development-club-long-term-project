## Contributors: Richard Johnson
extends State

func enter() -> void:
	print("LOG: Entered COLLAPSE state")
	# 1. Play the death/collapse animation
	actor.play_animation("collapse")
	
	# 2. Stop all movement
	actor.velocity.x = 0
	actor.velocity.y = actor.gravity
	actor.direction = 0
	
	# 3. Disable the AI so it stops chasing the player
	if actor.mind:
		actor.mind.set_physics_process(false)
	
	if actor.player_detection:
		actor.player_detection.monitoring = false
		actor.target = null
	
	# 4. Turn off hitboxes/hurtboxes so the corpse can't hit or be hit
	actor.hitbox.monitoring = false
	actor.hurtbox.monitorable = false
	
	# 5. Optional: Disable collision with the player 
	# (so you can walk over the bones)
	actor.collision_layer = 0

func physics_update(delta: float) -> void:
	if not actor.sprite.is_playing() or actor.sprite.animation != "collapse":
		# Stop the _physics_process and _process functions
		actor.set_physics_process(false)
		actor.set_process(false)
		
		if actor.body:
			actor.body.set_physics_process(false)
