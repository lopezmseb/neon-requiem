extends Control
@onready var join_card = $HBoxContainer/JoinCard
var players = 0
var Max_Players = 4
var first_player_device_id = -1  # -1 for keyboard, or the ID for the first controller
var button_pressed_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	# Debugging
	await get_tree().process_frame  # Ensure scene tree is built
	
	if join_card:
		join_card.player_joined.connect(_on_player_joined)
	if $"Menu Music":
		fade_in_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_joined(player_id: int, device_id: int, device_type: String, sprite: String):
	# Instantiate PlayerCard
	var new_player = preload("res://Scenes/UI/PlayerCard.tscn").instantiate()
	$HBoxContainer.add_child(new_player)

	# Show character sprite
	new_player.get_node("ColorRect/Character").visible = true
	new_player.get_node("ColorRect/Character").texture = load(sprite)  
	new_player.get_node("ColorRect/Name").text = sprite.get_file().get_basename()
	# Assign device to the player
	new_player.assign_device(device_id)

	players += 1
	if players == Max_Players:
		join_card.queue_free()
	else:
		$HBoxContainer.move_child(join_card, players)
		
	# Enable the button for the first player only
	if players == 1:
		$Button.visible = true
		$Button.grab_focus()
		$Button.disabled = false
		first_player_device_id = device_id 
		print(first_player_device_id,device_id)

func _on_button_pressed():
	pass
	
func _input(event):
	# Check if the event is a button press (e.g., "ui_accept" action)
	if event is InputEventKey and event.pressed:
		# Handle keyboard input
		if -1 == first_player_device_id:
			
			# Allow first player to press the button
			if Input.is_action_just_pressed("ui_accept")  && button_pressed_count == 1:
				get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
			else: 
				button_pressed_count += 1
		elif event.device != first_player_device_id:
			# Prevent other players from interacting with the button
			print("Only the first player can press the button!")  # Optional debug message

	elif event is InputEventJoypadButton and event.pressed:
		# Handle controller input
		if event.device == first_player_device_id:
			# Allow first player to press the button
			if Input.is_action_just_pressed("ui_accept")  && button_pressed_count == 1:
				get_tree().change_scene_to_file("res://Scenes/TestScenes/GameLoop.tscn")
			else: 
				button_pressed_count += 1
		elif event.device != first_player_device_id:
			# Prevent other players from interacting with the button
			print("Only the first player can press the button!")  # Optional debug message	

func fade_in_music():
	var tween = get_tree().create_tween()
	$"Menu Music".volume_db = -40 
	$"Menu Music".play()
	tween.tween_property($"Menu Music", "volume_db", 0, 1)
