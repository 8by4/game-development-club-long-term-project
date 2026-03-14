## Contributors: Richard Johnson
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 1000
	health = 1000
	attack_power = 50
	attack_range = 120.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
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
	walk_speed = 20
	jump_height = 0
	
	ready_enemy() # from enemy.gd
