## Contributors: Mathew Carter, Richard Johnson
class_name Player
extends Actor

func _ready() -> void:
	# Overrides the Actor.gd default
	ai = false
	gravity = 512
	walk_speed = 128
	
	attack_power = 70
	
	ready() # from actor.gd

func _input(event: InputEvent) -> void:
	if collapsed:
#		if event.is_action_pressed("action"):
#			get_tree().reload_current_scene()
		return
	
	# Queue the jump action
	if event.is_action_pressed("jump"):
		jump_queued = true
		
		# Allow for variable jump heights:
		# If the button is released while moving up, reduce upward momentum
		if velocity.y < 0:
			var time_ratio = clamp(jump_timer / 1.0, 0.0, 1.0)
			var dynamic_cutoff = 0.5 + lerp(0.2, 0.5, time_ratio) 
			velocity.y *= dynamic_cutoff
	
	if event.is_action_pressed("action"):
		body.transition_to("Attack")
		return
		
#	if event.is_action_pressed("dash"):
#		state_machine.transition_to("Dash")
#		return

func _physics_process(delta: float) -> void:
	# 1. Capture continuous horizontal input (Movement Intent)
	if collapsed == false:
		direction = Input.get_axis("move_left", "move_right")
	
	# 2. Execute movement (The State has already modified velocity)
	# physics_update is defined in actor.gd
	physics_update(delta)
