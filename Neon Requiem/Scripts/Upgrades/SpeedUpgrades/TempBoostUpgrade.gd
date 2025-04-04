extends UpgradeStrategy
class_name TempBoostUpgrade

var increaseBy: int = 1

func _process(delta: float) -> void:
	upgradeText = "Go {speed}% faster when you pick up a Speed Boost consumable ".format({"speed":  25 * (level+1)})
	upgradeTitle = "Speed Boost Consumable Up"

func Apply(stat, extraData: Dictionary = {}):
	var player = get_owner() as Player
	
	if(player.isBoosted):
		return stat + 25 * level
	return stat
