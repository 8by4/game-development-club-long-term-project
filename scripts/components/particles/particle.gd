extends GPUParticles2D

func _ready():
	# Connect to the built-in signal that fires when 'One Shot' ends
	finished.connect(_on_finished)
	
	# Start emitting immediately when spawned
	emitting = true

func _on_finished():
	# Automatically clean up the node from the scene tree
	queue_free()
