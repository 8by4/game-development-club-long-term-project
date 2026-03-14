## Contributors: Richard Johnson
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 25
	health = 25
	attack_power = 5
	attack_range = 18.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = false
	knockback_enabled = true
	attack_uninterruptible = false
	attack_stationary = false
	fall_attack = false
	jump_attack = true
	jump_enabled = true
	fly_enabled = false
	fly_always = false
	patrol_enabled = true
	
	# Movement
	gravity = 384
	walk_speed = 100
	jump_height = -384
	
	ready_enemy() # from enemy.gd
