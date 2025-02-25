extends AddToStatUpgrade
class_name SwordAdditiveUpgrade

func _process(delta):
	upgradeText = "Add {attack} to your sword damage".format({"attack": baseAdditive * (level + 1)})
	upgradeTitle = "Sword Damage Up"
