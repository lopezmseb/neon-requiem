extends UpgradeStrategy

@export var cooldownToReset: CooldownComponent
@export var triggerAttack : String
@export var attackToReset : String

func _ready():
	maxLevel = 1
	upgradeText = "Reset your '{target}' cooldown when you kill with '{trigger}'".format({'trigger': triggerAttack, 'target': attackToReset})

func _process(delta):
	upgradeText = "Reset your '{target}' cooldown when you kill with '{trigger}'".format({'trigger': triggerAttack, 'target': attackToReset})

func Apply(stat: float, upgradeDict: Dictionary = {}):
	if(level != maxLevel and upgradeDict.has("target")):
		return stat
		
	var target = upgradeDict.get("target")
	var targetHealth = target.find_child("HealthComponent")
	
	if(targetHealth is HealthComponent and targetHealth.currentHealth - stat > 0):
		return stat
	
	# Cooldown cannot be 0
	cooldownToReset.timeout.emit()
	cooldownToReset.stop()
	
	return stat
	
	
	
