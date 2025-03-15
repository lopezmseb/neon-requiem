extends Control
class_name UpgradeSelect

@export var upgrades: Array[UpgradeStrategy] = []
@export var currentPlayerNumber = 1
@onready var upgradeContainer = $UpgradeContainer
@onready var upgradeScene = preload("res://Scenes/UI/UpgradeCard.tscn")
var player_save = "user://players.save"
var devices = []
var upgradeScenes = []
signal endSelection


func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property($Fade_Upgrade, "color:a", 0.5, 1)
	
	var count = 0
	focus_mode = Control.FOCUS_NONE
	
	var previous_card = null  # Track previous card for linking focus
	
	for upgrade in upgrades:
		var upgradeCard = upgradeScene.instantiate()
		upgradeCard.upgradeStrategy = upgrade
		upgradeCard.id = count
		count += 1
		
		upgradeCard.connect("onClick", onButtonPressed)
		upgradeContainer.add_child(upgradeCard)
		upgradeScenes.append(upgradeCard)

		# Set focus neighbors
		if previous_card:
			previous_card.focus_neighbor_right = upgradeCard.get_path()
			upgradeCard.focus_neighbor_left = previous_card.get_path()
		
		previous_card = upgradeCard  # Update previous card reference

	# Handle circular focus (first <-> last)
	if upgradeScenes.size() > 1:
		upgradeScenes[0].focus_neighbor_left = upgradeScenes[-1].get_path()
		upgradeScenes[-1].focus_neighbor_right = upgradeScenes[0].get_path()
	
	# Automatically focus the first card
	if upgradeScenes.size() > 0:
		upgradeScenes[0].grab_focus()
	
func _process(delta):		
	read_player_data()
	upgradeContainer.queue_redraw()	
	$Turn.text = "[center]Player {currentPlayer}'s Turn".format({"currentPlayer": int(currentPlayerNumber)})
	if(currentPlayerNumber - 1 < devices.size()):
		set_controller_device(devices[currentPlayerNumber - 1])
	var count = 0
	for i in upgradeScenes:

		if(is_instance_valid(i)):
			i.upgradeStrategy = upgrades[count] 
			count += 1
	
func read_player_data():
	if FileAccess.file_exists(player_save):
		var file = FileAccess.open(player_save, FileAccess.READ)

	# Read all lines from the file
		while file.eof_reached() == false:
			var line = file.get_line().strip_edges() 
			if line != "":
				# Split the line by commas (assuming CSV format)
				var data = line.split(",")

				if data.size() == 4:  # Ensure the line has exactly 3 values
					  # Convert player_counter to integer
					  # The device type is a string
					var device_id = int(data[2])  # Convert device_id to integer
					devices.append(device_id)
		file.close()  # Close the file after reading
		
func onButtonPressed(upgradeStrategy, id):
	set_controller_device(-1)
	endSelection.emit()
	
var current_device_id: int = -1  # Track the active controller

func set_controller_device(device_id: int):
	# If the device ID is -1, clear all controller inputs
	if device_id == -1:
		clear_all_controller_inputs()
	else:
		# If a different controller is assigned, clear the previous controller's inputs
		if current_device_id != -1 and current_device_id != device_id:
			clear_previous_controller_inputs(current_device_id)

		# Define directional mappings
		var directions = {
			"ui_left": { "button": 13, "axis": 0, "value": -1.0 },
			"ui_right": { "button": 14, "axis": 0, "value": 1.0 },
			"ui_up": { "button": 11, "axis": 1, "value": -1.0 },
			"ui_down": { "button": 12, "axis": 1, "value": 1.0 },
			"ui_accept": { "button": 0, "axis": null, "value": null },
			"ui_select": { "button": 1, "axis": null, "value": null }
		}

		# Loop through each action and reassign input
		for input_name in directions.keys():
			var data = directions[input_name]

			# Create button press input events
			if data.button != null:
				var button_event = InputEventJoypadButton.new()
				button_event.button_index = data.button
				button_event.device = device_id
				InputMap.action_add_event(input_name, button_event)

			# Create axis motion input events if necessary
			if data.axis != null:
				var axis_event = InputEventJoypadMotion.new()
				axis_event.axis = data.axis
				axis_event.axis_value = data.value
				axis_event.device = device_id
				InputMap.action_add_event(input_name, axis_event)
	
	# Update the active device ID
	current_device_id = device_id

# Function to clear all inputs for a controller
func clear_all_controller_inputs():
	for action in InputMap.get_actions():
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				if event.device == current_device_id:
					InputMap.action_erase_event(action, event)

# Function to clear inputs from the previous controller
func clear_previous_controller_inputs(device_id: int):
	for action in InputMap.get_actions():
		for event in InputMap.action_get_events(action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				if event.device == device_id:
					InputMap.action_erase_event(action, event)
