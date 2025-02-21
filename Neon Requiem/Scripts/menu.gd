extends Control



@onready var settings_menu = $SettingsMenu as SettingsMenu

func _ready():
	$"VBoxContainer/New GameButton".grab_focus()


func _process(delta):
	pass

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")

func _on_settings_pressed():
	settings_menu.visible = true
	
func _on_quit_pressed():
	get_tree().quit()
