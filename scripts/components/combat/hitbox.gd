## Copyright: UNCG Game Development Club Long-term Project
## Contributors: Dr. Richard B. Johnson
extends Area2D

func enter_attack_window():
	monitoring = true
	
	# Manually check for bodies already inside
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		_on_area_entered(area) # Force the signal logic to run

func _on_area_entered(area: Area2D) -> void:
	var attacker = get_parent()
	if attacker.not_attacking(): return
	var target = area.get_parent()
	
	if target.indestructible or target.blocking:
		if not attacker.deflected:
			attacker.deflected = true
			attacker.effects.spawn_deflection_effect(target)
	else:
		attacker.deflected = false
	
	if target.body.is_state("Hurt"):
		return # invisible for a short time while already hurt
	
	# Calculate direction for knockback
	target.knockback_direction = 1 if attacker.sprite.flip_h else -1	
	
	target.take_damage(attacker.attack_power, attacker.global_position)
	print("Hit connected!")
