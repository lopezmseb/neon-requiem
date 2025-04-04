extends Control

@onready var level_text = $VBoxContainer/Level
var save_path = "user://room.save"
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game_loop")
	$VBoxContainer/Restart.grab_focus()
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ) 
		level = file.get_var(level)
		_on_level_up(level)

func _on_level_up(level):
	level_text.text = "Floor Reached: {level}".format({"level": level})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_restart_pressed():
	if FileAccess.file_exists("user://room.save"):
		DirAccess.remove_absolute("user://room.save")
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
