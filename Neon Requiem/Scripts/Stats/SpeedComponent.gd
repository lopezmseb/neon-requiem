extends Node
class_name SpeedComponent

@export var baseSpeed = 100.0
var speed: float = baseSpeed
		
func calculateSpeed(speed = baseSpeed):
	var localSpeed = speed
	
	for i in get_children():
		var upgrade = i as UpgradeStrategy
		localSpeed = upgrade.Apply(localSpeed)
	
	return localSpeed
