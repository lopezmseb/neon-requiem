extends Node
class_name SpeedComponent

@export var startingSpeed = 100.0

func calculateSpeed():
	var speed = startingSpeed
	
	for i in get_children():
		var upgrade = i as UpgradeStrategy
		speed = upgrade.Apply(speed)
	
	return speed
