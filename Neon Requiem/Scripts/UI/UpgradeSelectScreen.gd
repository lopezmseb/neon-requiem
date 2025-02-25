extends Control
class_name UpgradeSelect

@export var upgrades: Array[UpgradeStrategy] = []
@onready var upgradeContainer = $UpgradeContainer
@onready var upgradeScene = preload("res://Scenes/UI/UpgradeCard.tscn")
var upgradeScenes = []
signal endSelection


func _ready():
	var tween = create_tween()
	tween.tween_property($Fade, "color:a", 0.5, 1)
	
	var count = 0
	
	for upgrade in upgrades:
		var upgradeCard = upgradeScene.instantiate()
		upgradeCard.upgradeStrategy = upgrade
		upgradeCard.id = count
		count = count + 1
		
		upgradeCard.connect("onClick", onButtonPressed)

		upgradeContainer.add_child(upgradeCard)
		
		upgradeScenes.append(upgradeCard)
		
		
		if(count == 1):
			upgradeCard.grab_focus()
	
func _process(delta):
	upgradeContainer.queue_redraw()	
	
	var count = 0
	for i in upgradeScenes:

		if(is_instance_valid(i)):
			i.upgradeStrategy = upgrades[count] 
			count += 1
	
func _input(event):
	if(event is InputEventJoypadButton):
		if(event.button_index == JOY_BUTTON_DPAD_LEFT || event.button_index == JOY_BUTTON_DPAD_RIGHT and upgradeScenes.size() > 0 ):
			print(event)
			#upgradeScenes[0].grab_focus()
	if(Input.is_key_pressed(KEY_DELETE)):
		get_tree().reload_current_scene()
		
func onButtonPressed(upgradeStrategy, id):
	print("onButtonPressed")
	# Remove picked Upgrade
	upgrades.remove_at(id)
	upgradeScenes.remove_at(id)

	endSelection.emit()
