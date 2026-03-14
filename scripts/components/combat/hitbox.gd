## Contributors: Richard Johnson
extends Area2D

func enter_attack_window():
# Toggle monitoring to force a fresh scan of the area
	monitoring = false
	monitoring = true
	
	# Manually check for bodies already inside
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		_on_area_entered(area) # Force the signal logic to run

func _on_area_entered(area: Area2D) -> void:
	var attacker = get_parent()
	
	if attacker.body.not_state("Attack"):
		return
	
	var victim = area.get_parent()
	
	if victim.body.is_state("Hurt"):
		return # invisible for a short time while already hurt
	
	# Calculate direction for knockback
	victim.knockback_direction = 1 if attacker.sprite.flip_h else -1	
	
	victim.take_damage(attacker.attack_power, attacker.global_position)
	print("Hit connected!")
