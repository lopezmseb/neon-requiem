extends Control
class_name UpgradeSelect

@export var upgrades: Array[UpgradeStrategy] = []
@onready var upgradeContainer = $UpgradeContainer
@onready var upgradeScene = preload("res://Scenes/UI/UpgradeCard.tscn")
signal endSelection


func _ready():
	var tween = create_tween()
	tween.tween_property($Fade, "color:a", 0.5, 1)
	
	for upgrade in upgrades:
		var upgradeCard = upgradeScene.instantiate()
		upgradeCard.upgradeStrategy = upgrade
		
		upgradeCard.connect("onClick", onButtonPressed)

		upgradeContainer.add_child(upgradeCard)

	
func _process(delta):
	upgradeContainer.queue_redraw()	
	
func _input(event):
	if(Input.is_key_pressed(KEY_DELETE)):
		get_tree().reload_current_scene()
		
func onButtonPressed():
	endSelection.emit()
	queue_free()
