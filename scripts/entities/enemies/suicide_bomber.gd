## Contributors: Richard Johnson
class_name SuicideBomber
extends FlyingEnemy

@export var explosion_radius: float = 64.0
@export var fuse_time: float = 0.4
var is_primed: bool = false

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
	patrol_enabled = false
	
	# Movement
	gravity = 512
	walk_speed = 100
	jump_height = 0

"""
func _physics_process(delta: float) -> void:
	if is_primed: return # Stop moving or "lunge" during fuse
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist < 30.0: # "Strike" distance
		start_detonation_sequence()
	else:
		hover_and_seek(delta)

func start_detonation_sequence():
	is_primed = true
	# Visual feedback is CRITICAL in rogue-likes
	$AnimationPlayer.play("prime_flash") 
	await get_tree().create_timer(fuse_time).timeout
	explode()

func explode():
	# Spawn an independent Explosion object so the damage 
	# persists even after this Enemy is freed
	var e = ExplosionScene.instantiate()
	e.global_position = self.global_position
	get_parent().add_child(e)
	
	self.queue_free() # The end of the Kamikaze
"""
