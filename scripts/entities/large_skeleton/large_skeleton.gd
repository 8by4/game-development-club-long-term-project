## Contributors: Mathew Carter, Richard Johnson
extends Actor

func _ready() -> void:
	# Overrides the Actor.gd default
	gravity = 512
	walk_speed = 50
	jump_height = -270
	
	max_health = 250
	health = 250
	attack_power = 10
	attack_range = 35.0
	attack_stationary = true
	
	#ready_navigation()
	
	ready() # from actor.gd
	set_variable_hitbox()

func _process(delta: float) -> void:
#	process_navigation()
#	update(delta) # see actor.gd
	pass

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		target = body
		mind.transition_to("Chase")

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		target = null
		mind.transition_to("Wait")

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
	var direction = sign(next_path_pos.x - global_position.x)
