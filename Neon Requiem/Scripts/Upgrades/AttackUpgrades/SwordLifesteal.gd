extends AddToStatUpgrade

func _ready() -> void:
	upgradeText = "Regain {percent}% of your sword damage as health when striking the opposite color!".format({"percent": baseAdditive * (level + 1)})
	upgradeTitle = "Sword Lifesteal"

func _process(delta: float) -> void:
	upgradeText = "Regain {percent}% of your sword damage as health when striking the opposite color!".format({"percent": baseAdditive * (level + 1)})
	upgradeTitle = "Sword Lifesteal"

func Apply(stat: float, dict: Dictionary = {}):
	if(not dict.has("source") and dict.has("target")):
		return stat
	
	# Get Values from Extra Dict
	var source = dict.get("source")
	var sourceHealth : HealthComponent = source.find_child("HealthComponent")
	var sourceColor : ColorComponent = source.find_child("ColorComponent")
	var target = dict.get("target")
	var targetColor : ColorComponent = target.find_child("ColorComponent")	
	var percentage = (baseAdditive * level)/100
	
	# If opposite color, heal damage
	if(sourceColor.color != targetColor.color):
		sourceHealth.currentHealth = clampf(sourceHealth.currentHealth + (stat * percentage), 0, sourceHealth.MAX_HEALTH)
	
	return stat
		
