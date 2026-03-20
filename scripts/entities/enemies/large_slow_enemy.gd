## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name LargeSlowEnemy
extends Enemy

func _ready() -> void:
	# Attributes
	max_health = 1000
	health = 1000
	attack_power = 50
	attack_range = 100.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = true
	block_enabled = false
	knockback_enabled = true
	attack_uninterruptible = true
	attack_stationary = true
	fall_attack = false
	jump_attack = false
	jump_enabled = false
	fly_enabled = false
	fly_always = false
	flying_bobber = false
	suicidal = false
	patrol_enabled = false
	
	# Movement
	gravity = 768
	walk_speed = 20
	jump_height = 0
	
	attack_cooldown = 3.0
	damage_begin_threshold = 0.3
	
	super.ready() # from enemy.gd
