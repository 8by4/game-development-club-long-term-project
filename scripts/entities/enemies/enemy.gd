## Copyright: UNCG Game Development Club Long-term Project
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

func get_self_direction_sign() -> float:
	return (-1.0 if sprite.flip_h else 1.0)

func get_self_direction() -> Vector2:
	return Vector2(get_self_direction_sign(), 0)

func get_direction_to_target_sign() -> float:
	var diff_x = target.global_position.x - global_position.x
	if abs(diff_x) < 0.1: # Dead Zone
		return get_self_direction_sign()
	return (-1.0 if diff_x < 0.0 else 1.0)

func get_direction_to_target() -> Vector2:
	return Vector2(get_direction_to_target_sign(), 0)

func get_direction() -> Vector2:
	if target:
		return get_direction_to_target()
	return get_self_direction()

func is_facing_target() -> bool:
	if not target: return false
	return get_self_direction_sign() == get_direction_to_target_sign()

func get_strike_edge_pos() -> Vector2:
	var dir = get_direction()
	var edge = hitbox_shape.shape.size / 2.0
	return global_position + dir * edge + Vector2(0, 20.0)

func can_spawn_effects() -> bool:
	if not attack_uninterruptible: return false
	if attack_effect_spawned: return false
	if attack_power < 50: return false
	if animation_is_finished("attack"): return false
	if get_animation_progress() < 0.5: return false
	return true

func spawn_impact_effect():
	var strength = remap(attack_power, 50.0, 100.0, 10.0, 30.0)
	var fade = remap(attack_power, 50, 100, 5.0, 3.0)
	apply_camera_shake(strength, fade)
	
	if attack_power >= 90:
		spawn_boulders_on_impact()
	else:
		spawn_sparks_on_impact()
	
	attack_effect_spawned = true

func spawn_boulders(pos: Vector2):
	var boulder = boulder_effect.instantiate()
	get_tree().current_scene.add_child(boulder)
	boulder.global_position = pos
	var look_target = pos + get_direction() * 100.0
	boulder.look_at(look_target)

func spawn_boulders_on_impact():
	var impact_pos = get_strike_edge_pos()
	spawn_boulders(impact_pos)

func spawn_sparks_on_impact():
	var impact_pos = get_strike_edge_pos()
	var spark = spark_effect.instantiate()
	get_tree().current_scene.add_child(spark)
	spark.global_position = impact_pos
	var look_target = impact_pos + get_direction() * 100.0
	spark.look_at(look_target)
