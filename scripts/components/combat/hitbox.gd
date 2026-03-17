## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
extends Area2D

func enter_attack_window():
# Toggle monitoring to force a fresh scan of the area
	monitoring = false
	monitoring = true
	
	# Manually check for bodies already inside
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		_on_area_entered(area) # Force the signal logic to run

func get_edge_pos(attacker: Actor, target: Actor) -> Vector2:
	var dir = (target.global_position - attacker.global_position).normalized()
	
	# The point where the attacker's reach ends
	var attacker_edge = attacker.hitbox_shape.shape.size.x / 2.0
	
	# Optional: If you want it on the ENEMY'S surface instead:
	# var target_edge = target.collision_shape.shape.radius # If using circles
	# return target.global_position - (dir * target_edge)
	
	return attacker.global_position + (dir * attacker_edge)

func _on_area_entered(area: Area2D) -> void:
	var attacker = get_parent()
	
	if attacker.body.not_state("Attack"):
		return
	
	var target = area.get_parent()
	
	if target.indestructible or target.blocking:
		attacker.deflected = true
		var impact_pos = get_edge_pos(attacker, target)
		attacker.spawn_spark(impact_pos, target.global_position)
	else:
		attacker.deflected = false
	
	if target.body.is_state("Hurt"):
		return # invisible for a short time while already hurt
	
	# Calculate direction for knockback
	target.knockback_direction = 1 if attacker.sprite.flip_h else -1	
	
	target.take_damage(attacker.attack_power, attacker.global_position)
	print("Hit connected!")
