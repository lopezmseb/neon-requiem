extends AddToStatUpgrade
class_name BulletAdditiveUpgrade

func _ready():
	
	upgradeText = "Add {attack} to your bullet damage".format({"attack": baseAdditive * (level + 1)})
	upgradeTitle = "Bullet Damage Up"
