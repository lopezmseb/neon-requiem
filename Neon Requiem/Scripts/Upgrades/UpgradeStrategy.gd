extends Node
class_name UpgradeStrategy

@export var upgradeImage = ""
@export var upgradeText = "Base"
@export var count = 0
	
func Apply(stat: float):
	pass
	
func OnPickup():
	count += 1
