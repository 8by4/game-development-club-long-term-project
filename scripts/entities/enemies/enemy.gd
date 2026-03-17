## Copyright: UNCG Game Development CLub Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name Enemy
extends Actor

# Optional AI State Behaviors
@export var patrol_enabled : bool = false

# Player Detection and Chase
@export var target: Player = null
@export var player_in_range: bool = false
@export var deadzone: float = 5.0

# Pathfinding and Navigation
@export var path_update_rate: float = 0.1
@onready var nav_agent: NavigationAgent2D = get_node_or_null('NavigationAgent2D')

func _ready() -> void:
	ready_enemy()
	
func ready_enemy() -> void:
	ai = self
	#ready_navigation()
	ready() # from actor.gd
	set_variable_hitbox()

func _process(_delta: float) -> void:
#	process_navigation()
#	update(delta) # see actor.gd
	pass

func _on_player_detection_body_entered(detected_body: Node2D) -> void:
	if detected_body is Player and not detected_body.collapsed:
		player_in_range = true
		target = detected_body
		mind.transition_to("Chase")

func _on_player_detection_body_exited(detected_body: Node2D) -> void:
	if detected_body is Player:
		disengage_target()

func disengage_target() -> void:
	player_in_range = false
	target = null
	mind.transition_to("Wait")
	
func no_more_target() -> bool:
	if not target: return true
	print(target.collapsed)
	return target.collapsed

## Both ready_navigation() and process_navigation() are prototypes
## for navigating the scene. For now, the skeleton will just chase 
## the player.
func ready_navigation() -> void:
	# Set the target (e.g., the Player)
	# In a real scenario, you'd update this dynamically
	nav_agent.target_position = Player.global_position

func process_navigation() -> void:
	if nav_agent.is_navigation_finished():
		direction = 0.0
		return
	
	# Calculate the next path position
	var next_path_pos = nav_agent.get_next_path_position()
	
	# Determine the horizontal direction (-1, 0, or 1)
	# Pass this "Intent" to the FSM via the shared variable
	var new_direction = sign(next_path_pos.x - global_position.x)
