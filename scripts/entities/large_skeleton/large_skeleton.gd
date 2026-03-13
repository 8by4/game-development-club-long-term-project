## Contributors: Mathew Carter, Richard Johnson
extends GroundEnemy

func _ready() -> void:
	max_health = 75
	health = 75
	attack_power = 25
	attack_range = 35.0
	
	attack_stationary = true
	jump_enabled = false
	patrol_enabled = false
	
	# Overrides the Actor.gd default
	gravity = 512
	walk_speed = 50
	jump_height = 0
	
	ready_enemy() # from ground_enemy.gd
