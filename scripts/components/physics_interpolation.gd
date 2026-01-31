extends Node2D

@export_node_path("Node2D") var target_node : NodePath = NodePath("..")
@onready var target : Node2D = get_node(target_node)

var last_pos : Vector2 = Vector2()
var current_pos : Vector2 = Vector2()

func _init() -> void:
	top_level = true

func _ready() -> void:
	global_position = target.global_position

func _physics_process(_delta : float) -> void:
	# save last position
	last_pos = current_pos
	# get current position
	current_pos = target.global_position

func _process(_delta : float) -> void:
	var f = Engine.get_physics_interpolation_fraction()
	global_position = last_pos + ((current_pos - last_pos) * f)
