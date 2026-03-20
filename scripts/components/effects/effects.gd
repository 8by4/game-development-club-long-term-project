## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
class_name Effects
#extends Resource

@export var spark_scene: PackedScene = preload("res://scenes/effects/deflection_spark.tscn")
@export var boulder_scene: PackedScene = preload("res://scenes/effects/boulders.tscn")
@export var explosion_scene: PackedScene = preload("res://scenes/effects/explosion.tscn")
var attack_effect_spawned : bool = false
var glow_tween : Tween # for the chrome glow effect
var actor : Actor

func _init(linked_actor : Actor):
	actor = linked_actor

func apply_camera_shake(strength: float, fade: float):
	var camera = actor.get_viewport().get_camera_2d()
	camera.apply_shake(strength, fade)

func blink(duration: float, frequency: float) -> void:
	var tween = actor.create_tween().set_loops(int(duration / frequency))
	tween.tween_property(actor.sprite, "visible", false, frequency / 2.0)
	tween.tween_property(actor.sprite, "visible", true, frequency / 2.0)
	
	# Ensure sprite is visible when finished
	tween.finished.connect(func(): actor.sprite.visible = true)

func chrome_glow() -> bool:
	if not actor.sprite or not actor.sprite.material is ShaderMaterial:
		return false
		
	var mat = actor.sprite.material as ShaderMaterial
	
	# 1. THE RESET: Kill the old animation if it's still running
	if glow_tween:
		glow_tween.kill()
	
	# 2. Reset the shader parameter to max immediately
	# This ensures that even if the last hit was at 0.2 intensity, 
	# it snaps back to 1.0 for the new hit.
	mat.set_shader_parameter("hit_intensity", 1.0)
	
	# 3. Create a fresh tween
	glow_tween = actor.create_tween()
	
	# 4. Animate back to zero
	# Using TRANS_EXPO or TRANS_QUART makes the 'fade' feel more metallic/snappy
	glow_tween.tween_property(mat, "shader_parameter/hit_intensity", 0.0, 0.6)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	return true

func spawn_deflection_spark(pos: Vector2, target_pos: Vector2):
	var spark = spark_scene.instantiate()
	actor.get_tree().current_scene.add_child(spark)
	spark.global_position = pos
	spark.look_at(target_pos)
	spark.rotation += PI # Flip 180 degrees to face away

func spawn_deflection_effect(target: Actor):
	var impact_pos = actor.get_attacker_edge_pos(target)
	spawn_deflection_spark(impact_pos, target.global_position)

func spawn_sparks(pos: Vector2, target_pos: Vector2):
	var spark = spark_scene.instantiate()
	actor.get_tree().current_scene.add_child(spark)
	spark.global_position = pos
	spark.look_at(target_pos)

func spawn_boulders(pos: Vector2, target_pos: Vector2):
	var boulder = boulder_scene.instantiate()
	actor.get_tree().current_scene.add_child(boulder)
	boulder.global_position = pos
	boulder.look_at(target_pos)

func spawn_explosion(pos: Vector2, _radius: float):
	# Spawn an independent Explosion object so the damage 
	# persists even after this Enemy is freed
	var explosion = explosion_scene.instantiate()
	explosion.global_position = pos
	actor.get_parent().add_child(explosion)

func apply_bobbing(delta: float, pursuit_vel_y: float = 0.0):
	var bob_offset = compute_bobbing(delta)
	actor.velocity.y = pursuit_vel_y + bob_offset

func compute_bobbing(delta: float) -> float:
	# 1. Get the current animation data
	var sprite_frames = actor.sprite.sprite_frames
	var anim_name = actor.sprite.animation
	
	# 2. Calculate the loop duration in seconds
	var frame_count = sprite_frames.get_frame_count(anim_name)
#	var fps = sprite_frames.get_animation_speed(anim_name) # Issues!
	
	# Avoid division by zero if FPS is somehow 0
#	var loop_duration = frame_count / max(fps, 0.001)
	var loop_duration = float(frame_count)
	
	# 3. Factor in the sprite's specific playback speed scale
	actor.flying_time_passed += delta * actor.sprite.speed_scale

	# 4. Wrap the time so it stays between 0 and loop_duration
	# This prevents floating point errors over long play sessions
	actor.flying_time_passed = fmod(actor.flying_time_passed, loop_duration)
	
	# 5. Standard Sine math
	var frequency = 2.0 * (2.0 * PI) / loop_duration
	var bob_offset = sin(actor.flying_time_passed * frequency) * actor.flying_bob_height
	
	return bob_offset

func fade_away() -> void:
	var tween = actor.create_tween().set_parallel(true)
	var purple_tint = Color(0.1, 0.05, 0.3, 0.0)
#	var purple_tint = Color(0.15, 0.05, 0.3, 0.0) 
#	var purple_tint = Color(0.2, 0.1, 0.4, 0.0) 
	
	tween.tween_property(actor.sprite, "self_modulate", purple_tint, actor.fade_away_time).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	if actor.is_ai(): actor.queue_free()
