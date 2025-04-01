extends Node2D
@onready var tileMap: TileMap = $TileMap

var players = []

func _ready() -> void:
	$UserInterface.setPlayer($Player)
	$StaticEnemy2/ColorComponent.color = COLORS.OFFENSIVE
	players.append($Player)

func _process(delta: float) -> void:	
	
	tileDamage()
	if($Player.position == Vector2(999999,999999)):
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Scenes/TutorialGameOver.tscn")
		return
	var total = count_character2d_excluding_player(get_tree().current_scene)
	if (total == 0):
		get_tree().change_scene_to_file("res://Scenes/TutorialWin.tscn")
	if Input.is_action_just_pressed("Menu"):
		$UserInterface/SettingsMenu.visible = true
		get_tree().paused = true
		await get_tree().process_frame  # Ensures UI updates before setting focus

		var close_button = $UserInterface/SettingsMenu/MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton
		close_button.grab_focus()
		
		
func count_character2d_excluding_player(node):
	var count = 0
	
	# Check if the current node is a CharacterBody2D and not named "Player"
	if node is CharacterBody2D and node.name != "Player" and node is not Bullet:
		count += 1

	# Recursively check all children
	for child in node.get_children():
		count += count_character2d_excluding_player(child)

	return count
	
func tileDamage():
	if(not GlobalVariables.allowDamageFromFloors):
		return
		
	for player in players:
		if(player is Player):
			var tilePosition = tileMap.local_to_map(to_local(player.global_position))
			var atlasCoords = tileMap.get_cell_atlas_coords(0, tilePosition)
			
			var playerHealth = player.find_child("HealthComponent") as HealthComponent
			var playerColor = player.find_child("ColorComponent") as ColorComponent
			if(not playerColor):
				continue
				
			if(atlasCoords == Vector2i(4,1)):
				if(playerColor.color == COLORS.OFFENSIVE):
					continue
					
				if(playerHealth):
					playerHealth.damage($TileDamage)
					
			elif(atlasCoords == Vector2i(4,3)):
				if(playerColor.color == COLORS.DEFENSIVE):
					continue
					
				if(playerHealth):
					playerHealth.damage($TileDamage)
	
