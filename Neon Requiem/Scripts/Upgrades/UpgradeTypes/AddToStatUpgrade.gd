extends UpgradeStrategy
class_name AddToStatUpgrade

@export var baseAdditive = 2


func Apply(stat: float):
	return stat + pow(baseAdditive, count)
