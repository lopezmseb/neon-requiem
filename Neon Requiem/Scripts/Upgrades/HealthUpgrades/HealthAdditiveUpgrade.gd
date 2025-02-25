extends AddToStatUpgrade
class_name HealthAdditiveUpgrade

func _process(delta):
	baseAdditive = 10
	upgradeText = "Add {health} to your max health!\nCurrent Stack: +{currentAdd}".format({"health": baseAdditive, "currentAdd": baseAdditive * level})
	upgradeTitle = "Health Up"

func Apply(health: float):
	return health + baseAdditive * level
