## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name FlyingEnemy
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 50
	health = 50
	attack_power = 10
	attack_range = 16.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = false
	block_enabled = false
	knockback_enabled = true
	attack_uninterruptible = false
	attack_stationary = false
	fall_attack = false
	jump_attack = false
	jump_enabled = false
	fly_enabled = true
	fly_always = true
	flying_bobber = true
	patrol_enabled = false
	
	# Movement
	gravity = 10
	walk_speed = 75
	jump_height = 0
	
	flying = true
	flying_speed = 75.0
	fade_away_time = 0.7
	
	super.ready() # from enemy.gd
