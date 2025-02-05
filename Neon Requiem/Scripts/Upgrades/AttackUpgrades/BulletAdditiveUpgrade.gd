extends AddToStatUpgrade
class_name BulletAdditive 

func _ready():
	upgradeText = "Add ${attack} to your bullet damage".format({"attack": baseAdditive * (count + 1)})
