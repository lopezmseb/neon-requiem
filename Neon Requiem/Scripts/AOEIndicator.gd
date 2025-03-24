extends Area2D

@export var timer: Timer = null

func _ready() -> void:
	if(timer):
		timer.start()
		timer.timeout.connect(onTimeout)
		
func onTimeout():
	var bodies = get_overlapping_bodies()
	
	queue_free()
