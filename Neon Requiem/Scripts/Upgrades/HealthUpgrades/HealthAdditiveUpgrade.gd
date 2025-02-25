extends AddToStatUpgrade
class_name HealthAdditiveUpgrade

var startingHealth = 100

func _process(delta):
	baseAdditive = 10
	upgradeText = "Add {health} to your max health!\nCurrent Health: {currentAdd}".format({"health": baseAdditive, "currentAdd": Apply(startingHealth)})
	upgradeTitle = "Health Up"

func Apply(health: float):
	return health + baseAdditive * level
