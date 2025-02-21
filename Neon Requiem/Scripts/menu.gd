extends Control


@onready var Music_Bus_ID = AudioServer.get_bus_index("Music")
@onready var SFX_Bus_ID = AudioServer.get_bus_index("SFX")
@onready var settings_menu = %SettingsMenu

func _ready():
	$"VBoxContainer/New GameButton".grab_focus()
	settings_menu.visible = false


func _process(delta):
	pass

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")

func _on_settings_pressed():
	settings_menu.visible = !settings_menu.visible
	
func _on_quit_pressed():
	get_tree().quit()


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Music_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Music_Bus_ID, value < 0.05)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_Bus_ID, value < 0.05)


func _on_button_pressed():
	settings_menu.visible = !settings_menu.visible
