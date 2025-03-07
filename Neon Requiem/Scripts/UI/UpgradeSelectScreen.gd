extends Control
class_name UpgradeSelect

@export var upgrades: Array[UpgradeStrategy] = []
@export var currentPlayerNumber = 1
@onready var upgradeContainer = $UpgradeContainer
@onready var upgradeScene = preload("res://Scenes/UI/UpgradeCard.tscn")
var upgradeScenes = []
signal endSelection


func _ready():
	
	var tween = get_tree().create_tween()
	tween.tween_property($Fade_Upgrade, "color:a", 0.5, 1)
	
	var count = 0
	focus_mode = Control.FOCUS_ALL
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
	$Turn.text = "[center]Player {currentPlayer}'s Turn".format({"currentPlayer": currentPlayerNumber})
	set_controller_device(currentPlayerNumber - 1)
	var count = 0
	for i in upgradeScenes:

		if(is_instance_valid(i)):
			i.upgradeStrategy = upgrades[count] 
			count += 1
	
	
func _input(event):
	if(Input.is_key_pressed(KEY_DELETE)):
		get_tree().reload_current_scene()
		
func onButtonPressed(upgradeStrategy, id):
	set_controller_device(-1)
	endSelection.emit()
	
func set_controller_device(device_id: int):
	# Define directional mappings
	var directions = {
		"ui_left": { "button": 13, "axis": 0, "value": -1.0 },  # D-pad Left, Left Stick Left
		"ui_right": { "button": 14, "axis": 0, "value": 1.0 },  # D-pad Right, Left Stick Right
		"ui_up": { "button": 11, "axis": 1, "value": -1.0 },  # D-pad Up, Left Stick Up
		"ui_down": { "button": 12, "axis": 1, "value": 1.0 },   # D-pad Down, Left Stick Down
		"ui_accept": { "button": 0, "axis": null, "value": null },  # Typically A (Xbox) / Cross (PlayStation)
		"ui_select": { "button": 1, "axis": null, "value": null } 
	}

	# Loop through each direction and reassign input
	for input_name in directions.keys():
		# Remove the old mapping
		InputMap.erase_action(input_name)
		InputMap.add_action(input_name)

		# Get direction settings
		var data = directions[input_name]

		# Create a new button event (D-pad)
		var button_event = InputEventJoypadButton.new()
		button_event.button_index = data.button  # D-pad button
		button_event.device = device_id  # Assign to specific controller
		InputMap.action_add_event(input_name, button_event)
		
		
		# Create a new axis event (Analog Stick)
		if data.axis != null:
			var axis_event = InputEventJoypadMotion.new()
			axis_event.axis = data.axis
			axis_event.axis_value = data.value
			axis_event.device = device_id
			InputMap.action_add_event(input_name, axis_event)
