extends Control



@onready var settings_menu = $SettingsMenu as SettingsMenu

func _ready():
	$"VBoxContainer/New GameButton".grab_focus()


func _process(delta):
	pass


func _on_new_game_pressed():
	if FileAccess.file_exists("user://room.save"):
		DirAccess.remove_absolute("user://room.save")
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
	
		

func _on_settings_pressed():
	settings_menu.visible = true
	await get_tree().process_frame  # Ensures UI updates before setting focus
	
	var close_button = $SettingsMenu/MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton
	close_button.grab_focus()
	
func _on_quit_pressed():
	get_tree().quit()


func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
