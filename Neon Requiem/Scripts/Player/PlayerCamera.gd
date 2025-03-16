extends Camera2D
class_name PlayerCamera

@export var cameraMultiplier: float = 3
var miniMapOpen = false
func _process(delta):
	var window_size = DisplayServer.window_get_size()
	
	var x: float  = window_size.x as float
	var y :float = window_size.y as float
	
	zoom = Vector2(x/y * cameraMultiplier, x/y * cameraMultiplier)
	
func _input(event):
	if event.is_action_pressed("map"):
		var player = get_parent().find_children("Player", "Player", true, false)[0]
		if not player:
			return
		if((event is not InputEventKey) and (event.device == player.playerController)) || ((event is InputEventKey) and (player.playerController == -1)):
			if miniMapOpen:
				cameraMultiplier = 3
				miniMapOpen = false
				player.set_physics_process(true)
			else: 
				cameraMultiplier = 0.75
				miniMapOpen = true
				player.set_physics_process(false)
