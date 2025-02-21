class_name SettingsMenu

extends Control

@onready var settings_menu = $"."
@onready var Music_Bus_ID = AudioServer.get_bus_index("Music")
@onready var SFX_Bus_ID = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	$"MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton".grab_focus()
	
	if Input.is_action_just_pressed("Menu"):
		settings_menu.visible = false
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(Music_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(Music_Bus_ID, value < 0.05)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_Bus_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_Bus_ID, value < 0.05)


func _on_close_button_pressed():
	settings_menu.visible = false
	get_tree().paused = false
	await get_tree().process_frame  # Ensures UI updates before setting focus
	
	var close_button = $"../VBoxContainer/New GameButton"
	if close_button:
		close_button.grab_focus()
	

func _on_quit_button_pressed():
	get_tree().quit()
	
