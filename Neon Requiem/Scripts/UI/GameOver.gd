extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game_loop")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")


func _on_quit_pressed():
	get_tree().quit()
