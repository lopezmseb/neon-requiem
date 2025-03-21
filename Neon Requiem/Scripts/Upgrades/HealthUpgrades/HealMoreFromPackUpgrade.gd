extends HealthPackUpgrade
class_name HealMoreUpgrade

@export var increase_amount : float = 10

func _ready() -> void:
	upgradeText = "Heal {amount} more health from Health Packs!".format({"amount": increase_amount * (level + 1)})
	upgradeTitle = "Sword Lifesteal"

func _process(delta: float) -> void:
	upgradeText = "Heal {amount} more health from Health Packs!".format({"amount": increase_amount * (level + 1)})
	upgradeTitle = "Sword Lifesteal"

func Apply(stat: float, dict: Dictionary = {}):
	return stat + increase_amount * level		
