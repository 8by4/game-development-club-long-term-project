## Contributors: Matthew Carter, Richard Johnson
extends Camera2D

@export_node_path("Node2D") var target_node : NodePath = NodePath("..")
@onready var target : Node2D = get_node(target_node)
@export var speed : float = 5.0

var shake_strength: float = 0.0
var shake_fade: float = 2.0 # How fast the shake stops

func _ready() -> void:
	top_level=true
	global_position = target.global_position

func _process(delta : float) -> void:
	global_position = lerp(global_position, target.global_position, speed * delta) 
	
	if shake_strength > 0:
		# Gradually reduce the shake over time
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		
		# Apply a random offset within the current strength
		global_position += Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

func apply_shake(strength: float):
	shake_strength = strength
