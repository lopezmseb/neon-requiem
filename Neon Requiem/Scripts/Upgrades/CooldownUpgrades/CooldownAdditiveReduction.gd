extends AddToStatUpgrade
class_name CooldownAdditiveReduction

@export var ability = "Ability"

func _ready():
	baseAdditive= -0.5
	upgradeText = "Subtract {value}s to your {ability}".format({"value": baseAdditive * (level + 1), "ability": ability})
	upgradeTitle = "Cooldown Reduction"

func Apply(baseStat: float):
	return baseStat + (baseAdditive * level)
