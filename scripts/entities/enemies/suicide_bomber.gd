## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name SuicideBomber
extends FlyingEnemy

@export var explosion_radius: float = 64.0
@export var fuse_time: float = 0.4

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
	
	super.ready() # from enemy.gd

func start_detonation_sequence():
	is_primed = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(fuse_time).timeout
	
	hitbox.monitoring = true
	hitbox.enter_attack_window()
	hitbox_shape.shape.size.x = explosion_radius * 2.0
	hitbox_shape.shape.size.y = explosion_radius * 2.0
	
	effects.spawn_explosion(global_position, explosion_radius)
	await get_tree().create_timer(0.3).timeout
	
	collapsed = true
	hitbox.monitoring = false
	body.transition_to("Collapse")
