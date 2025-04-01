extends Control



@onready var settings_menu = $SettingsMenu as SettingsMenu

func _ready():
	$"VBoxContainer/New GameButton".grab_focus()
	fade_in_music()


func _process(delta):
	pass


func _on_new_game_pressed():
	if FileAccess.file_exists("user://room.save"):
		DirAccess.remove_absolute("user://room.save")
	if FileAccess.file_exists("user://players.save"):
		DirAccess.remove_absolute("user://players.save")
	var savesDir = DirAccess.open("user://saves/")
	for file in savesDir.get_files():
		DirAccess.remove_absolute("user://saves/" + file)
	get_tree().change_scene_to_file("res://Scenes/UI/PlayerJoin.tscn")
	
		

func _on_settings_pressed():
	settings_menu.visible = true
	await get_tree().process_frame  # Ensures UI updates before setting focus
	
	var close_button = $SettingsMenu/MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton
	close_button.grab_focus()
	
func _on_quit_pressed():
	get_tree().quit()


func _on_continue_button_pressed():
	if FileAccess.file_exists("user://players.save"):
		DirAccess.remove_absolute("user://players.save")
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
	
func fade_in_music():
	var tween = create_tween()
	$"Menu Music".volume_db = -40 
	$"Menu Music".play()
	tween.tween_property($"Menu Music", "volume_db", 0, 1) 
