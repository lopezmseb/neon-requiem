extends Node
class_name UpgradeStrategy

@export_file("*.png") var upgradeImagePath
@export var upgradeId: float
@export var upgradeImage : CompressedTexture2D
@export var upgradeTitle = ""
@export var upgradeText = "Base"
@export var color = null
@export var level = 0
@export var priority = 0
@export var maxLevel = 999

func Apply(stat: float, extraData: Dictionary = {}):
	pass
	
func OnPickup():
	level += 1
