extends Actor

#@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var target : Node2D

## The variable we use to toggle AI behavior
var chase : bool = false
var player_in_range: bool = false
## Reference to the player for pathfinding calculations
var target_player: Player = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _init() -> void:
	# Overrides the Actor.gd default
	gravity = 512
	walk_speed = 50
	jump_height = 270

func _ready() -> void:
	#ready_navigation()
	pass

func _process(_delta: float) -> void:
	#process_navigation()
	follow_player()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		target_player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		target_player = null

func follow_player() -> void:
	# Simple AI: Walk toward player if seen, else 0
	if target_player and player_in_range:
		# Set the 'intent' variable for the FSM to read
		direction = sign(target_player.global_position.x - global_position.x)
	else:
		# Stop moving if the player is gone
		direction = 0

## Both ready_navigation() and process_navigation() are prototypes
## for navigating the scene. For now, the skeleton will just use a 
## simplistic player follow approach.
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

"""
# PREVIOUS IMPLEMENTATION OF LARGE_SKELETON
extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var chase : bool = false
var speed : float = 50
var target : Node2D

func _physics_process(_delta : float) -> void:
	if chase == true:
		var direction = (target.position - self.position).normalized()
		if direction.x > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		velocity.x = direction.x * speed
	else:
		velocity.x = 0
	move_and_slide()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		sprite.play("walk")
		target = body
		chase = true

func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		sprite.play("idle")
		target = body
		chase = false
"""
