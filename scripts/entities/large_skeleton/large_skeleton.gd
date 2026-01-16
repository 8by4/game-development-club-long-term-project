extends CharacterBody2D

@onready var SPEED = 50
@onready var player : Player  = get_node("../Player")
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var chase : bool = false

func _physics_process(_delta : float) -> void:
	if chase == true:
		var direction = (player.position - self.position).normalized()
		if direction.x > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		velocity.x = direction.x * SPEED
	else:
		velocity.x = 0
	move_and_slide()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
