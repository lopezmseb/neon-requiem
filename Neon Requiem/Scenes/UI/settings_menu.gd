class_name SettingsMenu

extends Control

var save_path = "user://settings.save"
var master_volume = 1
var music_volume = 1
var SFX_volume = 1

@onready var settings_menu = $"."
@onready var Master_Bus_ID = AudioServer.get_bus_index("Master")
@onready var Music_Bus_ID = AudioServer.get_bus_index("Music")
@onready var SFX_Bus_ID = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	$"MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton".grab_focus()
	load_data()
	
	if Input.is_action_just_pressed("Menu"):
		settings_menu.visible = false
		get_tree().paused = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Master_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Master_Bus_ID, value < 0.05)
	master_volume = value
	
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Music_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Music_Bus_ID, value < 0.05)
	music_volume = value


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_Bus_ID, value < 0.05)
	SFX_volume = value


func _on_close_button_pressed():
	settings_menu.visible = false
	get_tree().paused = false
	await get_tree().process_frame  # Ensures UI updates before setting focus
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(master_volume)
	file.store_var(music_volume)
	file.store_var(SFX_volume)
	
	var close_button = $"../VBoxContainer/New GameButton"
	if close_button:
		close_button.grab_focus()
	

func _on_quit_button_pressed():
	get_tree().quit()
	
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ) 
		$"MarginContainer2/MarginContainer/VBoxContainer/GridContainer/Master Slider".value = file.get_var(master_volume)
		$"MarginContainer2/MarginContainer/VBoxContainer/GridContainer/Music Slider".value = file.get_var(music_volume)
		$"MarginContainer2/MarginContainer/VBoxContainer/GridContainer/SFX Slider".value = file.get_var(SFX_volume)
		


