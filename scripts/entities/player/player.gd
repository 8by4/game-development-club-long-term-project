class_name Player
extends Actor

func _init() -> void:
	# Overrides the Actor.gd default
	gravity = 512
	walk_speed = 128
	jump_height = 270

func _process(delta: float) -> void:
	# 1. Update the State Machine's visual logic
	if state_machine:
		state_machine.update(delta)
	
	# 2. Handle Sprite Flipping (Standard for both Player and Enemy)
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_queued = true
	
#	if event.is_action_pressed("attack"):
#		# You can trigger transitions directly from input if preferred
#		state_machine.TransitionTo("Attack")

#	if event.is_action_pressed("dash"):
#		# You can signal the FSM to check for transition
#		state_machine.TransitionTo("Dash")

func _physics_process(delta: float) -> void:
	# 1. Capture continuous horizontal input (Movement Intent)
	direction = Input.get_axis("move_left", "move_right")
		
	# 2. Execute movement (The State has already modified velocity)
	# actor_move_and_slide is defined in actor.gd
	actor_move_and_slide(delta)

"""
# PREVIOUS IMPLEMENTATION OF PLAYER
extends CharacterBody2D
class_name Player
# movement
var gravity : int = 512
var walk_speed : int = 128
var jump_height : int = 270
# input
var direction : float = 0
var jump_queued : bool = false
# nodes
@onready var sprite : AnimatedSprite2D = $Sprite

func _input(_event : InputEvent) -> void:
	direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("jump") : jump_queued = true
	
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

func _physics_process(delta : float) -> void:
	var target_velocity : Vector2 = Vector2(direction * walk_speed, 0)
	
	if is_on_floor():
		velocity = velocity.lerp(target_velocity, (16 * delta))
		if jump_queued:
			velocity.y = -jump_height
			sprite.play("jump")
		else:
			if direction == 0:
				sprite.play("idle")
			else:
				sprite.play("walk")
	else:
		sprite.play("jump") # falling
		velocity.y += gravity * delta
		if velocity.dot(Vector2(direction,0)) < 64:
			velocity += target_velocity * delta
	
	move_and_slide()
	jump_queued = false
"""
