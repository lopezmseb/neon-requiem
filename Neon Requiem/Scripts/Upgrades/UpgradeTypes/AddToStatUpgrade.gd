extends UpgradeStrategy
class_name AddToStatUpgrade

@export var baseAdditive: float = 2

func Apply(stat: float, extraData: Dictionary = {}):
	return stat + baseAdditive*level
