extends CharacterBody2D
var player

func _physics_process(delta: float) -> void:
	player = get_node("../../Player")
	var direction = (player.position - self.position).normalized()
	if direction.x > 0:
		get_node("AnimatedSprite2D").flip_h = false
	else:
		get_node("AnimatedSprite2D").flip_h = true

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		pass
