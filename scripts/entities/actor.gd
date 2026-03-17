## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name Actor
extends CharacterBody2D

# This reference will now be shared by all children (Player/Enemies)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Generated assets
@export var spark_scene: PackedScene = preload("res://scenes/effects/deflection_spark.tscn")

## --- Golden Metrics (Editable in Inspector) ---
@export_group("Movement Metrics")
@export var walk_speed : float = 100.0
@export var run_speed : float = 200.0
@export var jump_height : float = -400.0
@export var acceleration : float = 1200.0
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
var jump_timer : float = 0.0
var coyote_time : float = 0.0
var coyote_threshold : float = 0.3
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## --- Entity Data ---
@export var max_health : int = 100
@export var health : int = 100
@export var attack_power : int = 10
@export var attack_range : float = 20.0 # For AI
@onready var hitbox: Area2D = $Hitbox 
@onready var hurtbox: Area2D = $Hurtbox 
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitCollisionShape2D
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/HurtCollisionShape2D
@onready var hitbox_max_width : float = 0.0
@onready var hitbox_min_width : float = 0.0
@onready var hitbox_variable : bool = false
@export var land_stun_threashold : float = 300.0

## --- Abilities ---
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

@export var attack_cooldown : float = 0.2
@export var attack_cooldown_timer : float = 0.0
@export var knockback_direction : int = 0
@export var knockback_scale : float = 1.0
@export var fade_away_time : float = 0.7

var blocking : bool = false
var deflected : bool = false
var repelled: bool = false
var collapsed : bool = false

# Visual Effects
var glow_tween : Tween

func _ready() -> void:
	ready()

func ready() -> void:
	if body: body.initial_state = $BodyFSM/Idle
	if mind: mind.initial_state = $MindFSM/Wait
	
	hitbox.monitoring = false
	hurtbox.monitorable = true
	
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()

func set_attack_cooldown() -> void:
	attack_cooldown_timer = attack_cooldown

func can_attack_again() -> bool:
	if body.is_state("Attack"): return false
	if not jump_attack and body.is_state("Jump"): return false
	if not fall_attack and body.is_state("Fall"): return false
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
	var frames = sprite.sprite_frames.get_frame_count("attack")
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
		
		if not body.is_state("attack"):
			attack_cooldown_timer -= delta
	
	move_and_slide()

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

func can_jump() -> bool:
	return jump_enabled and (coyote_time < coyote_threshold)

func take_damage(amount: int, source_position: Vector2) -> void:
	if collapsed: return
	if body.is_state("Hurt"): return
	
	if not ai and amount >= 50:
		var camera = get_viewport().get_camera_2d()
		var shake_strength = remap(amount, 50.0, 100.0, 7.5, 15.0)
		camera.apply_shake(shake_strength, 2.5)
		
	if not indestructible:
		health -= amount
		if health <= 0:
			collapsed = true
	
	if body.is_state("Attack") and attack_uninterruptible:
		pass
	else:
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

func blink(duration: float, frequency: float) -> void:
	var tween = create_tween().set_loops(int(duration / frequency))
	tween.tween_property(sprite, "visible", false, frequency / 2.0)
	tween.tween_property(sprite, "visible", true, frequency / 2.0)
	
	# Ensure sprite is visible when finished
	tween.finished.connect(func(): sprite.visible = true)

func chrome_glow() -> bool:
	if not sprite or not sprite.material is ShaderMaterial:
		return false
		
	var mat = sprite.material as ShaderMaterial
	
	# 1. THE RESET: Kill the old animation if it's still running
	if glow_tween:
		glow_tween.kill()
	
	# 2. Reset the shader parameter to max immediately
	# This ensures that even if the last hit was at 0.2 intensity, 
	# it snaps back to 1.0 for the new hit.
	mat.set_shader_parameter("hit_intensity", 1.0)
	
	# 3. Create a fresh tween
	glow_tween = create_tween()
	
	# 4. Animate back to zero
	# Using TRANS_EXPO or TRANS_QUART makes the 'fade' feel more metallic/snappy
	glow_tween.tween_property(mat, "shader_parameter/hit_intensity", 0.0, 0.6)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	return true

func spawn_spark(pos: Vector2, target_pos: Vector2):
	var spark = spark_scene.instantiate()
	get_tree().current_scene.add_child(spark)
	spark.global_position = pos
	
	# Look away from the target so sparks fly toward the player/air
	spark.look_at(target_pos)
	spark.rotation += PI # Flip 180 degrees to face away

func fade_away() -> void:
	var tween = create_tween().set_parallel(true)
	var purple_tint = Color(0.1, 0.05, 0.3, 0.0)
#	var purple_tint = Color(0.15, 0.05, 0.3, 0.0) 
#	var purple_tint = Color(0.2, 0.1, 0.4, 0.0) 
	
	tween.tween_property(sprite, "self_modulate", purple_tint, fade_away_time).set_trans(Tween.TRANS_SINE)

	await tween.finished
	if ai: queue_free()
