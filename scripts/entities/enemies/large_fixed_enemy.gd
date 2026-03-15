## Contributors: Richard Johnson
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 1000
	health = 1000
	attack_power = 100.0
	attack_range = 80.0
	
	# Abilities
	move_enabled = false
	turning_enabled = false
	indestructible = true
	knockback_enabled = true
	attack_uninterruptible = true
	attack_stationary = true
	fall_attack = false
	jump_attack = false
	jump_enabled = false
	fly_enabled = false
	fly_always = false
	patrol_enabled = false
	
	# Movement
	gravity = 768
	walk_speed = 0
	jump_height = 0
	
	ready_enemy() # from enemy.gd
