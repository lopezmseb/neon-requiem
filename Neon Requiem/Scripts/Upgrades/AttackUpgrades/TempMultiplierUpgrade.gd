extends UpgradeStrategy
class_name TempMultiplierUpgrade

@export var enableBoost: bool = false
@export var multiplier: float = 1.0

func _ready():
	showOnUpgradeSelectScreen = false

func Apply(stat: float, upgradeDict: Dictionary = {}):
	# Get Multiplier Attack and then reset multiplier
	var attack = stat * multiplier
	multiplier = 1
	# Else multiply it
	return attack
	
	
	
