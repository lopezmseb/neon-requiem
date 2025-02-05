extends AddToStatUpgrade
class_name HealthAdditive 

func _ready():
	upgradeText = "Add ${health} to your max health!".format({"attack": pow(baseAdditive, count + 1)})

func Apply(health: float):
	return health + baseAdditive * count
