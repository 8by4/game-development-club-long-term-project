## Contributors: Richard Johnson
class_name Actor
extends CharacterBody2D

# This reference will now be shared by all children (Player/Enemies)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## --- Golden Metrics (Editable in Inspector) ---
@export_group("Movement Metrics")
@export var walk_speed: float = 100.0
@export var run_speed: float = 200.0
@export var jump_height: float = -400.0
@export var acceleration: float = 1200.0
#@export var friction: float = 800.0

## The variable we use to toggle AI behavior
@export_group("AI Settings")
@onready var mind: StateMachineManager = get_node_or_null('MindFSM')
@export var ai : bool = true
@export var chase : bool = false
@onready var player_detection = get_node_or_null('PlayerDetection')
@export var target: Player = null
@export var player_in_range: bool = false
@export var player_in_reach: bool = false
@export var deadzone: float = 5.0

## Reference to the player for pathfinding calculations
@export var path_update_rate: float = 0.1
@onready var nav_agent: NavigationAgent2D = get_node_or_null('NavigationAgent2D')

## --- Body State Data ---
@onready var body: StateMachineManager = $BodyFSM
var direction : float = 0.0
var start_height : float = 0.0
var jump_queued : bool = false
var jump_timer : float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## --- Entity Data ---
@export var max_health : int = 100
@export var health : int = 100
@export var attack_power : int = 10
@export var attack_range : float = 20.0 # For AI
@export var attack_stationary : bool = false
@onready var hitbox: Area2D = $Hitbox 
@onready var hurtbox: Area2D = $Hurtbox 
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitCollisionShape2D
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/HurtCollisionShape2D
@onready var hitbox_max_width : float = 0.0
@onready var hitbox_min_width : float = 0.0
@onready var hitbox_variable : bool = false
@export var land_stun_threashold : float = 300.0
var knockback_direction : int = 0
var collapsed : bool = false

func _ready() -> void:
	ready()

func ready() -> void:
	if body: body.initial_state = $BodyFSM/Idle
	if mind: mind.initial_state = $MindFSM/Wait
	
	hitbox.monitoring = false
	hurtbox.monitorable = true

func set_variable_hitbox() -> void:
	hitbox_max_width = hurtbox_shape.shape.size.x
	hitbox_min_width = hitbox_max_width / 2.0
	attack_range = 	hitbox_min_width + 5
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
	# 2. Ping-pong the progress so 0.0 -> 0.0, 0.5 -> 1.0, 1.0 -> 0.0
	var weight = 1.0 - abs(2.0 * (progress - 0.5))
	# 3. Interpolate the width
	var current_width = lerp(hitbox_min_width, hitbox_max_width, weight)
	
	# 4. Apply to shape
	set_hitbox_width(current_width)

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
	
	if body: body.physics_update(delta)
		
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

func take_damage(amount: int, source_position: Vector2) -> void:
	if collapsed: return
	
	health -= amount
	
	if health <= 0:
		collapse()
	else:
		body.transition_to("Hurt")

func collapse() -> void:
	collapsed = true
	body.transition_to("Collapse")

func revive() -> void:
	health = max_health
	velocity = Vector2.ZERO
	
	hitbox.monitoring = false
	hurtbox.monitorable = true
	collision_layer = 1
	
	if body: body.transition_to("Idle")
	if mind: mind.transition_to("Wait")
	
	if body: body.set_physics_process(true)
	if mind: mind.set_physics_process(true)
	
	set_physics_process(true)
	set_process(true)

func blink(duration: float, frequency: float) -> void:
	var tween = create_tween().set_loops(int(duration / frequency))
	tween.tween_property(sprite, "visible", false, frequency / 2.0)
	tween.tween_property(sprite, "visible", true, frequency / 2.0)
	
	# Ensure sprite is visible when finished
	tween.finished.connect(func(): sprite.visible = true)
