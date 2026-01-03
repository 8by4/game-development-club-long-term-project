extends CharacterBody2D

@onready var player : Player  = get_node("../Player")
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta : float) -> void:
	var direction = (player.position - self.position).normalized()
	if direction.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		pass
