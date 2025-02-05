extends Camera2D
class_name PlayerCamera

@export var cameraMultiplier: float = 3
func _process(delta):
	var window_size = DisplayServer.window_get_size()
	
	var x: float  = window_size.x as float
	var y :float = window_size.y as float
	
	zoom = Vector2(x/y * cameraMultiplier, x/y * cameraMultiplier)
