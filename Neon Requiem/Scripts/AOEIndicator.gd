extends Area2D

@export var timer: Timer = null
@export var attackComponent: AttackComponent

func _ready() -> void:
	if(timer):
		timer.start()
		timer.timeout.connect(onTimeout)
		
func onTimeout():
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if(body is Player):
			var healthComponent: HealthComponent = body.find_child("HealthComponent")
			
			healthComponent.damage(attackComponent)
	
	queue_free()
