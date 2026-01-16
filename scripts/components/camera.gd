extends Camera2D

@export_node_path("Node2D") var target_node : NodePath = NodePath("..")
@onready var target : Node2D = get_node(target_node)

func _ready() -> void:
	top_level=true
	global_position = target.global_position

func _process(delta : float) -> void:
	global_position = lerp(global_position,target.global_position, 5 * delta)
