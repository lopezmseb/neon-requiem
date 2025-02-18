extends AddToStatUpgrade
class_name HealthAdditiveUpgrade

func _ready():
	baseAdditive = 10
	upgradeText = "Add {health} to your max health!".format({"health": pow(baseAdditive, level + 1)})
	upgradeTitle = "Health Up"

func Apply(health: float):
	return health + baseAdditive * level
