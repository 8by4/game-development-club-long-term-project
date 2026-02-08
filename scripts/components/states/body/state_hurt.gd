## Contributors: Richard Johnson
extends State

# Configurable metrics for the hit reaction
@export var knockback_force: Vector2 = Vector2(-200, -150)
@export var stun_duration: float = 0.4
var timer: float = 0.0

func enter() -> void:
	print("LOG: Entered HURT state")
	actor.play_animation("hurt")
	
	# Start blinking for 1.5 seconds every 0.1 seconds
	actor.blink(1.5, 0.1)
	
	# 1. Apply Knockback
	actor.velocity = Vector2(knockback_force.x * actor.knockback_direction, knockback_force.y)  
	
	# 2. Reset timer
	timer = stun_duration

func physics_update(delta: float) -> void:
	# 3. Apply Gravity while in hit-stun
	actor.velocity.y += actor.gravity * delta 
	
	# 4. Handle Stun Timer
	timer -= delta
	if timer <= 0:
		if actor.is_on_floor():
			state_machine_manager.transition_to("Idle")
		else:
			state_machine_manager.transition_to("Fall")
