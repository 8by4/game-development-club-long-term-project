## Copyright: UNCG Game Development Club Long-term Project
extends CanvasLayer

# --- Nodes ---
@onready var player : Player = get_parent()
@onready var health_bar : ProgressBar = $HealthBar

func _ready() -> void:
	player.health_changed.connect(set_health_value)

func set_health_value(value : int) -> void:
	health_bar.value = value
