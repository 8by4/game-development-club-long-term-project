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

@export_group("AI Settings")
@export var path_update_rate: float = 0.1
@export var deadzone: float = 5.0

## --- State Data ---
@onready var state_machine: StateMachineManager = $StateMachineManager
var direction : float = 0.0
var jump_queued : bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	state_machine.initial_state = $StateMachineManager/Idle


func _process(delta: float) -> void:
	update(delta)

func update(delta: float) -> void:
	if state_machine:
		state_machine.update(delta)

func _physics_process(delta: float) -> void:
	# Universal movement execution
	physics_update(delta)

func physics_update(delta: float) -> void:
	# Handle Sprite Flipping (Standard for both Player and Enemy)
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
		
	if state_machine:
		state_machine.physics_update(delta)
		
	move_and_slide()

func play_animation(anim_name: String) -> void:
	if sprite: 
		sprite.play(anim_name)
	else:
		printerr("Warning: No sprite found on ", anim_name)
