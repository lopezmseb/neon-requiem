extends AddToStatUpgrade
class_name HealthAdditiveUpgrade

var startingHealth = 100

func _process(delta):
	upgradeText = "Add {health} to your max health!\nCurrent Health: {currentAdd}".format({"health": baseAdditive, "currentAdd": Apply(startingHealth)})
	upgradeTitle = "Health Up"

func Apply(health: float, extraData: Dictionary = {}):
	return health + baseAdditive * level
