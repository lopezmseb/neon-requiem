extends UpgradeStrategy
class_name AddToStatUpgrade

@export var baseAdditive: float = 2


func Apply(stat: float):
	return stat + pow(baseAdditive, level)
