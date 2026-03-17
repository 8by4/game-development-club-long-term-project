## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name LargeFixedEnemy
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 1000
	health = 1000
	attack_power = 100
	attack_range = 80.0
	
	# Abilities
	move_enabled = false
	turning_enabled = false
	indestructible = true
	block_enabled = false
	knockback_enabled = false
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
	
	attack_cooldown = 5.0
	
	ready_enemy() # from enemy.gd
