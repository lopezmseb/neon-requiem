extends UpgradeStrategy
class_name TempMultiplierUpgrade

var enableBoost: bool = false
@export var multiplier: float = 1.0 

func _ready():
	showOnUpgradeSelectScreen = false

func Apply(stat: float, upgradeDict: Dictionary = {}):
	# Get Multiplier Attack and then reset multiplier
	if(enableBoost):
		print("In Herererere")
		changeEnable(false)
		enableBoost = false
		enableBoost = false
		enableBoost = false
		return stat * multiplier
	
	return stat
	
func changeEnable(value: bool):
	enableBoost = value
