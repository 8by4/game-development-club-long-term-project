extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var chase : bool = false
var speed : float = 50
var target : Node2D

func _physics_process(_delta : float) -> void:
	if chase == true:
		var direction = (target.position - self.position).normalized()
		if direction.x > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		velocity.x = direction.x * speed
	else:
		velocity.x = 0
	move_and_slide()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		sprite.play("walk")
		target = body
		chase = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		sprite.play("idle")
		target = body
		chase = false
