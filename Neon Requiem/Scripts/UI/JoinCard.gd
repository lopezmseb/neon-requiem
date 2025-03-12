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

var characters = ["res://Assets/Characters/Jex.png","res://Assets/Characters/GRIM.png","res://Assets/Characters/Volt.png","res://Assets/Characters/Nyx.png"]


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
		var file : FileAccess
		if FileAccess.file_exists(save_path):
			file = FileAccess.open(save_path, FileAccess.READ_WRITE)
			file.seek_end()
		else:
			file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_line(str(player_counter) + "," + device_type + "," + str(device_id)+","+characters[player_counter].get_file().get_basename())
		
		player_counter += 1
		player_joined.emit(player_counter, device_id, device_type, characters[player_counter - 1])
