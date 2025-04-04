extends AddToStatUpgrade

@export var tempMultiplierUpgrade : TempMultiplierUpgrade
@export var triggerAttack : String
@export var attackToBoost : String

func _ready():
	upgradeText = "On '{trigger}' kill, your next '{target}' attack will do {percent}% damage".format({'trigger': triggerAttack, 'target': attackToBoost, 'percent': 100 + (100*baseAdditive*(level+1))})

func _process(delta):
	upgradeText = "On '{trigger}' kill, your next '{target}' attack will do {percent}% damage".format({'trigger': triggerAttack, 'target': attackToBoost, 'percent': 100 + (100*baseAdditive*(level+1))})

func Apply(stat: float, upgradeDict: Dictionary = {}):
	# If boost timer is not running, boost might be eligible, check other conditions
	if(not upgradeDict.has("target")):
		return stat
	
	var target = upgradeDict.get("target")
	var targetHealth = target.find_child("HealthComponent")
	
	# If we don't kill on this next hit, return base stat
	if(not targetHealth is HealthComponent):
		return stat
		
	if(targetHealth.currentHealth - stat <= 0):
		if(not tempMultiplierUpgrade.enableBoost):
			print("In here")
			tempMultiplierUpgrade.multiplier = 1 + (baseAdditive * level)
			tempMultiplierUpgrade.enableBoost = true
		return stat
	# Set Multiplier Here
	return stat
