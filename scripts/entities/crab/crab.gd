## Contributors: Richard Johnson
extends GroundEnemy

func _ready() -> void:
	max_health = 25
	health = 25
	attack_power = 5
	attack_range = 20.0
	
	attack_stationary = false
	jump_enabled = true
	patrol_enabled = true
	
	# Overrides the Actor.gd default
	gravity = 512
	walk_speed = 100
	jump_height = -350
	
	ready_enemy() # from ground_enemy.gd
