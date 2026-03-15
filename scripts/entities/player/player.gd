## Contributors: Mathew Carter, Richard Johnson
class_name Player
extends Actor

func _ready() -> void:
	# Attributes
	max_health = 100
	health = 100
	attack_power = 25
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = false
	block_enabled = true
	knockback_enabled = true
	attack_uninterruptible = false
	attack_stationary = false
	fall_attack = true
	jump_attack = true
	jump_enabled = true
	fly_enabled = false
	fly_always = false
	ai = null
	
	# Movement
	gravity = 512
	walk_speed = 128
	jump_height = -400
	
	attack_cooldown = 0.0
	fade_away_time = 2.0
	
	ready() # from actor.gd

func _input(event: InputEvent) -> void:
	if collapsed:
#		if event.is_action_pressed("action"):
#			get_tree().reload_current_scene()
		return
	
	handle_input_jump(event)
	handle_input_action(event)
	
#	if event.is_action_pressed("dash"):
#		state_machine.transition_to("Dash")
#		return

func handle_input_jump(event: InputEvent) -> void:
	if not jump_enabled: return
	
	# 1. Trigger the Jump (Button Down)
	if event.is_action_pressed("jump"):
		jump_queued = true
		
	# 2. Variable Height (Button Up)
	if event.is_action_released("jump") and jump_enabled:
		# Allow for variable jump heights:
		# If the button is released while moving up, reduce upward momentum
		if velocity.y < 0:
			var time_ratio = clamp(jump_timer / 1.0, 0.0, 1.0)
			var dynamic_cutoff = 0.5 + lerp(0.2, 0.5, time_ratio) 
			velocity.y *= dynamic_cutoff

func handle_input_action(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		# Context sensitive logic goes here
		
		if can_attack_again():
			body.transition_to("Attack")

func _physics_process(delta: float) -> void:
	# 1. Capture continuous horizontal input (Movement Intent)
	if collapsed == false and turning_enabled:
		direction = Input.get_axis("move_left", "move_right")
	
	# 2. Execute movement (The State has already modified velocity)
	# physics_update is defined in actor.gd
	physics_update(delta)
