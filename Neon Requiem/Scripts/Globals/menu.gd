extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$"VBoxContainer/New Game".grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/")

func _on_settings_pressed():
	#var settings = load().instance("settings scene")
	#get_tree().current_scene.add_child(settings)
	pass
	
func _on_quit_pressed():
	get_tree().quit()
