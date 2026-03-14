## Contributors: Richard Johnson
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 75
	health = 75
	attack_power = 25
	attack_range = 35.0
	
	# Abilities
	indestructible = false
	knockback_enabled = true
	attack_uninterruptible = false
	attack_stationary = true
	fall_attack = false
	jump_attack = false
	jump_enabled = false
	fly_enabled = false
	fly_always = false
	patrol_enabled = false
	
	# Movement
	gravity = 512
	walk_speed = 50
	jump_height = 0
	
	ready_enemy() # from enemy.gd
