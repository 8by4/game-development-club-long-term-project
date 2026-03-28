## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name Actor
extends CharacterBody2D

# This reference will now be shared by all children (Player/Enemies)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## --- Golden Metrics (Editable in Inspector) ---
@export_group("Movement Metrics")
@export var walk_speed : float = 100.0
@export var run_speed : float = 200.0
@export var flying_speed : float = 150.0
@export var jump_height : float = -400.0
@export var acceleration : float = 1200.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var knockback_force: Vector2 = Vector2(-200, -200)
#@export var friction: float = 800.0

## The variable we use to toggle AI behavior
@export_group("AI Settings")
@export var ai : Enemy = null
@onready var mind: StateMachineManager = get_node_or_null('MindFSM')
@onready var player_detection = get_node_or_null('PlayerDetection')

## --- Body State Data ---
@onready var body: StateMachineManager = $BodyFSM
var direction : float = 0.0
var start_height : float = 0.0
var jump_queued : bool = false
var blocking : bool = false
var deflected : bool = false
var repelled: bool = false
var collapsed : bool = false
var is_primed : bool = false
var flying : bool = false

## --- Timers ---
var attack_cooldown_timer : float = 0.0
var jump_timer : float = 0.0
var coyote_time : float = 0.0
var flying_time_passed = 0.0
var stun_timer: float = 0.0  # Hurt State
var fuse_time: float = 0.4

## --- Entity Data ---
@export_group("Entity Data")
@export var max_health : int = 100
@export var health : int = 100
@export var attack_power : int = 10

## --- Hitbox and Hurtbox ---
@onready var hitbox: Area2D = $Hitbox 
@onready var hurtbox: Area2D = $Hurtbox 
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitCollisionShape2D
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/HurtCollisionShape2D
@onready var hitbox_max_width : float = 0.0
@onready var hitbox_min_width : float = 0.0
@onready var hitbox_variable : bool = false

## --- Abilities ---
@export_group("Abilities")
@export var move_enabled : bool = true
@export var turning_enabled : bool = true
@export var indestructible : bool = false
@export var block_enabled : bool = false
@export var knockback_enabled : bool = true
@export var attack_uninterruptible : bool = false
@export var attack_stationary : bool = false
@export var fall_attack : bool = false
@export var jump_attack : bool = false
@export var jump_enabled : bool = false
@export var fly_enabled : bool = false
@export var fly_always : bool = false
@export var flying_bobber: bool = false
@export var suicidal : bool = false

## --- Thresholds ---
@export_group("Thresholds")
@export var attack_range : float = 20.0
@export var swoop_range : float = 200.0
@export var look_ahead : float = 0.3
@export var attack_cooldown : float = 0.2
@export var damage_begin_threshold = 0.3
@export var knockback_direction : int = 0
@export var knockback_scale : float = 1.0
@export var coyote_threshold : float = 0.3
@export var flying_bob_height : float = 25.0
@export var hover_height : float = -48.0
@export var stun_duration: float = 0.4 # Hurt State
@export var land_stun_threashold : float = 300.0
@export var explosion_radius: float = 64.0
@export var fade_away_time : float = 0.7

## --- Visual Effects ---
var attack_effect_spawned : bool = false
var effects : Effects;

## --- Signals ---
signal death ()

func _ready() -> void:
	ready()

func ready() -> void:
	if body: body.initial_state = $BodyFSM/Idle
	if mind: mind.initial_state = $MindFSM/Wait
	
	hitbox.monitoring = false
	hurtbox.monitorable = true
	
	effects = Effects.new(self)
	
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()

func set_attack_cooldown() -> void:
	attack_cooldown_timer = attack_cooldown

func can_attack_again() -> bool:
	if is_attacking(): return false
	if not jump_attack and body.is_state("Jump"): return false
	if not fall_attack and body.is_state("Fall"): return false
	if not attack_uninterruptible and body.is_state("Hurt"): return false
	if attack_stationary and not is_on_floor(): return false
	return attack_cooldown_timer <= 0.0

func set_variable_hitbox() -> void:
	hitbox_max_width = attack_range * 2.0
	hitbox_min_width = hitbox_max_width / 4.0
	set_hitbox_width(hitbox_min_width)
	hitbox_variable = true

func get_hitbox_width() -> float:
	return hitbox_shape.shape.size.x

func set_hitbox_width(width: float) -> void:
	hitbox_shape.shape.size.x = width

func reset_hitbox_width() -> void:
	set_hitbox_width(hitbox_min_width)
	
func update_hitbox_width() -> void:
	var frames = get_animation_frames_count()
	var current = sprite.frame
	
	# 1. Normalize progress (0.0 at start, 1.0 at last frame)
	var progress = float(current) / float(frames - 1)
	# 2. Find the weight based on progress
	var weight = compute_weight(progress, 0.75, 0.1)
	# 3. Interpolate the width
	var current_width = lerp(hitbox_min_width, hitbox_max_width, weight)
	
	# 4. Apply to shape
	set_hitbox_width(current_width)

func compute_weight(progress: float, hold: float, shake_intensity: float) -> float:
	var weight = 0.0
	hold = clamp(hold, 0.6, 0.95)
	
	if progress <= 0.6:
		weight = remap(progress, 0.0, 0.6, 0.0, 1.0)
	elif progress <= hold:
		weight = 1.0 + randf_range(-shake_intensity, shake_intensity)
	else:
		progress = remap(progress, hold, 1.0, 1.0, 0.0)
	
	# Safety clamp to ensure we never go below 0 or above 1
	return clamp(weight, 0.0, 1.0)

func _process(delta: float) -> void:
	update(delta)

func update(delta: float) -> void:
	if body: body.update(delta)

func _physics_process(delta: float) -> void:
	# Universal movement execution
	physics_update(delta)

func physics_update(delta: float) -> void:
	# Handle Sprite Flipping (Standard for both Player and Enemy)
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
	
	if body:
		body.physics_update(delta)
		
		if not_attacking():
			attack_cooldown_timer -= delta
	
	move_and_slide()

func is_player() -> bool:
	return not is_instance_valid(ai)

func is_ai() -> bool:
	return is_instance_valid(ai)

func play_animation(anim_name: String) -> void:
	if sprite: 
		# Check if the sprite has the animation before playing it
		if sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)
	else:
		printerr("Warning: No sprite found on ", anim_name)

func animation_is_finished(anim: String) -> bool:
	if sprite.animation != anim:
		return true
	
	var frame_count = sprite.sprite_frames.get_frame_count(anim)
	return sprite.frame == frame_count - 1

func set_animation_last_frame(anim: String) -> void:
	sprite.frame = sprite.sprite_frames.get_frame_count(anim) - 1

func get_animation_frames_count() -> int:
	var current_anim = sprite.animation
	return sprite.sprite_frames.get_frame_count(current_anim)

func get_animation_progress() -> float:
	var total_frames = get_animation_frames_count()
	return float(sprite.frame) / float(total_frames)

func get_movement_speed() -> float:
	if not move_enabled: return 0.0
	if flying: return flying_speed
	return walk_speed

func can_jump() -> bool:
	return jump_enabled and (coyote_time < coyote_threshold)

func update_flying_state():
	flying = fly_always or (fly_enabled and not is_on_floor())

func is_attacking():
	if body.is_state("Attack"): return true
	if body.is_state("Swoop_Attack"): return true
	return body.is_state("Critical")

func not_attacking():
	return not is_attacking()

func get_attacker_edge_pos(target: Actor) -> Vector2:
	var dir = (target.global_position - global_position).normalized()
	# The point where the attacker's reach ends
	var attacker_edge = hitbox_shape.shape.size.x / 2.0
	return global_position + (dir * attacker_edge)

func get_target_edge_pos(target: Actor) -> Vector2:
	var dir = (target.global_position - global_position).normalized()	
	# If you want it on the ENEMY'S surface instead:
	var target_edge = target.hitbox_shape.shape.size.x / 2.0
	return target.global_position - (dir * target_edge)

func take_damage(amount: int, _source_position: Vector2) -> void:
	if collapsed: return
	if body.is_state("Hurt"): return
	
	if not indestructible:
		health -= amount
		if health <= 0:
			collapsed = true
			death.emit()
	
	if not (body.is_state("Attack") and attack_uninterruptible):
		knockback_scale = (amount / 25.0) * 0.5 + 0.5
		body.transition_to("Hurt")

func revive() -> void:
	health = max_health
	velocity = Vector2.ZERO
	
	hitbox.monitoring = false
	hurtbox.monitorable = true
	collision_layer = 1
	
	if body: body.transition_to("Idle")
	if mind: mind.transition_to("Wait")
	
#	if body: body.set_physics_process(true)
#	if mind: mind.set_physics_process(true)
	
	set_physics_process(true)
	set_process(true)
