extends Control
var Max_Players = 4
var save_path = "user://players.save"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

signal player_joined(player_id: int, device_id: int, device_type: String, sprite:String)
var device_to_player = {}  # Dictionary to store the device and corresponding player number
var player_counter = 0  # Counter to assign player numbers
var devices_seen = {}  # Dictionary to track devices and their type (keyboard or controller)

var characters = ["res://Assets/Characters/Boss.png","res://Assets/Characters/Boss.png","res://Assets/Characters/Boss.png","res://Assets/Characters/Boss.png"]


func _input(event):
	if(player_counter <= Max_Players):
		if event is InputEventKey:
			handle_device(-1, "keyboard")
		elif event is InputEventJoypadButton:
			handle_device(event.device, "controller")

func handle_device(device_id: int, device_type: String):
	# Assign a player number if this is a new device
	if device_id not in device_to_player:
		device_to_player[device_id] = player_counter
		devices_seen[device_id] = device_type
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_var([player_counter,device_type,device_id ])
		
		print("Assigned Player ", player_counter, " to ", device_type, " Device ID: ", device_id)
		player_counter += 1
		player_joined.emit(player_counter, device_id, device_type, characters[player_counter - 1])


