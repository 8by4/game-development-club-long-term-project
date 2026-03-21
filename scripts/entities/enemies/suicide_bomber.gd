## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name SuicideBomber
extends FlyingEnemy

func _ready() -> void:
	# Attributes
	max_health = 5
	health = 5
	attack_power = 50
	attack_range = 60.0
	
	# Abilities
	move_enabled = true
	turning_enabled = true
	indestructible = false
	block_enabled = false
	knockback_enabled = true
	attack_uninterruptible = true
	attack_stationary = false
	fall_attack = true
	jump_attack = false
	jump_enabled = false
	fly_enabled = true
	fly_always = true
	flying_bobber = false
	suicidal = true
	patrol_enabled = false
	
	# Movement
	gravity = 0
	walk_speed = 100
	jump_height = 0
	hover_height = 0.0
	
	look_ahead = 0.1
	fuse_time = 1.0
	
	super.ready() # from enemy.gd
