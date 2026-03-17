## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name HeavyEnemy
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 75
	health = 75
	attack_power = 25
	attack_range = 32.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = false
	block_enabled = true
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
	
	attack_cooldown = 1.0
	fade_away_time = 1.2
	
	ready_enemy() # from enemy.gd
