extends Control

var assigned_device: int = -1  # Default: No device assigned
var player_ready = true
func _ready():
	pass
	# Set focus mode to allow the button to receive input 
# Function to assign a specific device ID to this UI element
func assign_device(device_id: int):
	assigned_device = device_id
	print(name, "  is now assigned to device ", assigned_device)
