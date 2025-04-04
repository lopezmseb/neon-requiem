extends AddToStatUpgrade
class_name CooldownAdditiveReduction

@export var ability = "Ability"
@export var time = 0
func _process(delta):
	upgradeText = "Lower cooldown by {value}s to your {ability}".format({"value": baseAdditive , "ability": ability})
	if(time > 0):
		upgradeText += "\nCurrent Cooldown: {newValue}".format({"newValue": Apply(time)})
	upgradeTitle = "Cooldown Reduction"

func Apply(baseStat: float, extraData: Dictionary = {}):
	time = baseStat
	return clampf(baseStat - (baseAdditive * level), 0.1, 10)
