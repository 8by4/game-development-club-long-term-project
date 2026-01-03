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
@onready var sprite : Sprite2D = $Sprite

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
		if jump_queued : velocity.y = -jump_height
	else:
		velocity.y += gravity * delta
		if velocity.dot(Vector2(direction,0)) < 64:
			velocity += target_velocity * delta
	
	move_and_slide()
	jump_queued = false
