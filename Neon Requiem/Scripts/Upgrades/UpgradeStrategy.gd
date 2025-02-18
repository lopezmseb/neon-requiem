extends Node
class_name UpgradeStrategy

@export var upgradeImage = ""
@export var upgradeTitle = ""
@export var upgradeText = "Base"
@export var level = 0
	
func Apply(stat: float):
	pass
	
func OnPickup():
	level += 1
