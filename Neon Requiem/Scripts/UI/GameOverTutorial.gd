extends Control

@onready var level_text = $VBoxContainer/Level
var save_path = "user://room.save"
var level: int = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game_loop")
	$VBoxContainer/Restart.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
