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
@onready var mind: StateMachineManager = $MindFSM
@export var ai : bool = true
@export var chase : bool = false
@onready var player_detection = $PlayerDetection
@export var target: Player = null
@export var player_in_range: bool = false
@export var player_in_reach: bool = false
@export var deadzone: float = 5.0

## Reference to the player for pathfinding calculations
@export var path_update_rate: float = 0.1
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

## --- Body State Data ---
@onready var body: StateMachineManager = $BodyFSM
var direction : float = 0.0
var start_height : float = 0.0
var jump_queued : bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## --- Entity Data ---
@export var max_health : int = 100
@export var health : int = 100
@export var attack_power : int = 10
@export var attack_range: float = 20.0 # For AI
@onready var hitbox: Area2D = $Hitbox 
@onready var hurtbox: Area2D = $Hurtbox 
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@export var land_stun_threashold : float = 300.0
var knockback_direction : int = 0
var collapsed : bool = false

func _ready() -> void:
	ready()

func ready() -> void:
	body.initial_state = $StateMachineManager/Idle
	
	if mind:
		mind.initial_state = $StateMachineManager/Wait

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
		sprite.play(anim_name)
	else:
		printerr("Warning: No sprite found on ", anim_name)

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

func blink(duration: float, frequency: float) -> void:
	var tween = create_tween().set_loops(int(duration / frequency))
	tween.tween_property(sprite, "visible", false, frequency / 2)
	tween.tween_property(sprite, "visible", true, frequency / 2)
	
	# Ensure sprite is visible when finished
	tween.finished.connect(func(): sprite.visible = true)

func get_state() -> String:
	return body.current_state.name.to_lower();

func is_state(state: String) -> bool:
	return state.to_lower() == get_state()

func not_state(state: String) -> bool:
	return state.to_lower() != get_state()
