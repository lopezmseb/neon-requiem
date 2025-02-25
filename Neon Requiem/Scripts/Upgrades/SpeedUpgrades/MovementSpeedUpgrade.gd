extends AddToStatUpgrade
class_name MovementSpeedUpgrade

func _process(delta):
	baseAdditive = 0.25
	upgradeText = "Add {speed}% to your max speed! (Stackable)".format({"speed": 25})
	upgradeTitle = "Movement Speed Up"

func Apply(speed: float):
	return speed + (speed* baseAdditive * level)
