extends ProgressBar
#created by Brenden Reyes(BeanBoiOfficial)

@export var target_actor : Actor 

func _ready() -> void:
	if target_actor:
		
		max_value = target_actor.max_health
		
		
		target_actor.HealthChanged.connect(update_bar)
		
		
		update_bar()
	else:
		push_warning("HealthBar: No target_actor assigned in Inspector!")

func update_bar() -> void:
	if target_actor:

		value = target_actor.health
