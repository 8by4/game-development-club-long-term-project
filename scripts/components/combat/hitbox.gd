## Contributors: Richard Johnson
extends Area2D

func enter_attack_window():
	monitoring = true
	# Manually check for bodies already inside
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		_on_area_entered(area) # Force the signal logic to run

func _on_area_entered(area: Area2D) -> void:
	var attacker = get_parent()
	
	if attacker.not_state("attack"):
		return
	
	var victim = area.get_parent()
	
	if victim.is_state("hurt"):
		return # invisible for a short time while already hurt
	
	# Calculate direction for knockback
#	var impact_dir = (victim.global_position - attacker.global_position).normalized()
	# We flip the X force based on which way the actor is facing
	victim.knockback_direction = 1 if attacker.sprite.flip_h else -1	
	
	victim.take_damage(attacker.attack_power, attacker.global_position)
	print("Hit connected!")
