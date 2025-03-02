extends Control
@onready var join_card = $HBoxContainer/JoinCard
var players = 0
var Max_Players = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	# Debugging
	await get_tree().process_frame  # Ensure scene tree is built

	if join_card:
		join_card.player_joined.connect(_on_player_joined)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_joined(player_id: int, device_id: int, device_type: String, sprite: String):
	print("New Player Joined! ID:", player_id, "Device:", device_type)
	$Button.visible = true
	$Button.grab_focus()
	$Button.set_focus_mode(2)

	# Instantiate PlayerCard
	var new_player = preload("res://Scenes/UI/PlayerCard.tscn").instantiate()
	$HBoxContainer.add_child(new_player)

	# Show character sprite
	new_player.get_node("ColorRect/Character").visible = true
	new_player.get_node("ColorRect/Character").texture = load(sprite)  

	# Assign device to the player
	new_player.assign_device(device_id)


	players += 1
	if players == Max_Players:
		join_card.queue_free()
	else:
		$HBoxContainer.move_child(join_card, players)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
