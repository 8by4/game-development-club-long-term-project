## Contributors: Richard Johnson
extends State

# Configurable metrics for the hit reaction
@export var knockback_force: Vector2 = Vector2(-200, -200)
@export var stun_duration: float = 0.4
var stun_timer: float = 0.0

func enter() -> void:
	print_debug_log("Entered HURT state")
	actor.play_animation("hurt")
	
	# Start blinking for 1.5 seconds every 0.1 seconds
	actor.blink(1.5, 0.1)
	
	# 1. Apply Knockback
	if actor.knockback_enabled:
		var f = knockback_force * actor.knockback_scale
		var x = f.x * actor.knockback_direction
		var v = Vector2(x, f.y)
		
		if actor.indestructible:
			actor.velocity = v / 8.0
		else:
			actor.velocity = v
	
	# 2. Reset timer
	stun_timer = stun_duration

func physics_update(delta: float) -> void:
	# 3. Apply Gravity while in hit-stun
	actor.velocity.y += actor.gravity * delta 
	
	# 4. Handle Stun Timer
	stun_timer -= delta
	if stun_timer <= 0:
		if actor.is_on_floor():
			if actor.collapsed:
				state_machine_manager.transition_to("Collapse")
			else:
				state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Fall")
