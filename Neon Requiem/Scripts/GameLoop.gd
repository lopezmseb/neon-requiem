extends Control

@onready var playerScene = preload("res://Scenes/Player.tscn")
@onready var enemyScene = preload("res://Scenes/BaseEnemy.tscn")
@onready var UIScene = preload("res://Scenes/UserInterface.tscn")
@onready var hbox = $HBoxContainer
@onready var mainViewport = $HBoxContainer/SubViewportContainer/SubViewport
@onready var mainCamera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D
@onready var roomGen : RoomGeneration = $HBoxContainer/SubViewportContainer/SubViewport/RoomGeneration
@onready var user_interface = $HBoxContainer/SubViewportContainer/SubViewport/UserInterface
@onready var fade = $Fade
@onready var enemiesNode = $HBoxContainer/SubViewportContainer/SubViewport/Enemies
@onready var settings_menu = $SettingsMenu
@onready var playerCamera = preload("res://Scripts/Player/PlayerCamera.gd")
@onready var upgradeSelectionScreen = preload("res://Scenes/UI/UpgradeSelectScreen.tscn")
var room_save = "user://room.save"
var player_save = "user://players.save"
var level: int = 1
var canChangeLevel : bool = false
var maxEnemiesPerRoom = 2
var players: Array[Player]
var enemies: Array[Node]
var viewports: Array[Viewport]
var upgradeSelectedCount: float = 0
var upgradeSelectScreen : UpgradeSelect = null

func _ready():
	add_to_group("game_loop")
	# Set Hbox to screensize
	if FileAccess.file_exists(room_save):
		var file = FileAccess.open(room_save, FileAccess.READ) 
		level = file.get_var(level)
		
	hbox.size = DisplayServer.window_get_size()
	# Set Pixel Style
	var subviewports = find_children("SubViewport")
	
	for i in subviewports:
		var subviewport = i as SubViewport
		viewports.append(subviewport)
		if(subviewport):
			subviewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
			subviewport.world_2d = mainViewport.world_2d
	
func save_player(player: Player, playerName: String):
	var save_directory = "user://saves/"
	var save_path = save_directory + "player_" + playerName + ".tscn"
	var dir = DirAccess.open("user://")

	# Ensure the directory exists before saving
	if dir:
		if not dir.dir_exists(save_directory):
			var result = dir.make_dir(save_directory)
			if result == OK:
				print("Directory created successfully")
			else:
				print("Failed to create directory")
		else:
			print("Directory already exists")
	else:
		print("Failed to open user:// directory")

	# Save the player scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(player)

	if result == OK:
		var error = ResourceSaver.save(packed_scene, save_path)
		if error == OK:
			print("Player data saved to", save_path)
		else:
			print("Failed to save player data:", error)
	else:
		print("Failed to pack player scene.")

		
func save_all_players():
	for player in players:
		save_player(player, player.playerName)
		
func load_player(playerName: String) -> Player:
	var save_path = "user://saves/player_" + playerName  + ".tscn"
	
	if ResourceLoader.exists(save_path):
		var packed_scene = ResourceLoader.load(save_path) as PackedScene
		if packed_scene:
			var player = packed_scene.instantiate() as Player
			print("Loaded Player with Upgrades from", save_path)
			return player
		else:
			print("Failed to load PackedScene.")
	else:
		print("No saved player found.")
	
	return null

func load_all_players():
	var loaded_any = false
	var playerNames = ["Jex","Grim","Volt","Nyx"]
	# Try to load each player by player_id
	for playername in playerNames:  # Adjust max_players as needed
		var player = load_player(playername)
		if(player != null):
			if(players.size() == 0 ):
				
				var remoteTransform := RemoteTransform2D.new()
				remoteTransform.remote_path = mainCamera.get_path()
				player.add_child(remoteTransform)
				user_interface.setPlayer(player)
				players.append(player)
				mainViewport.add_child(player)
			else:
				var container : SubViewportContainer = SubViewportContainer.new()
				var subViewport = SubViewport.new()
				var camera
				var playerInterface = UIScene.instantiate()
				var existing_camera = player.find_child("Camera2D", true, false)
				if existing_camera:
					camera = existing_camera
				else:
					camera = Camera2D.new()
					camera.set_script(playerCamera)
				
				# Player Config
				players.append(player)
				# UI Config
				playerInterface.setPlayer(player)
				# Camera Config
				# SubViewport Config 
				subViewport.world_2d = mainViewport.world_2d
				subViewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
				viewports.append(subViewport)
				# Container Config
				container.stretch = true
				container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				# Add Children to Scene
				subViewport.add_child(camera)
				subViewport.add_child(playerInterface)
				
				subViewport.add_child(player)		
				container.add_child(subViewport)
				hbox.add_child(container)
				subViewport.get_node("UserInterface/CooldownTimers").set_scale(Vector2(.5, .5))
				subViewport.get_node("UserInterface/PlayerHealthBar").set_scale(Vector2(.9, .9))
				update_grid() 
				# Remote Path to Camera
				var remoteTransform := RemoteTransform2D.new()
				remoteTransform.remote_path = camera.get_path()
				player.add_child(remoteTransform)
				# Spawn new Player into game
				roomGen.spawnPlayer(player, 0)
	
func read_player_data():
	if FileAccess.file_exists(player_save):
		var file = FileAccess.open(player_save, FileAccess.READ)

	# Read all lines from the file
		while file.eof_reached() == false:
			var line = file.get_line().strip_edges() 
			if line != "":
				# Split the line by commas (assuming CSV format)
				var data = line.split(",")

				if data.size() == 4:  # Ensure the line has exactly 3 values
					var player_counter = int(data[0])  # Convert player_counter to integer
					var device_type = data[1]  # The device type is a string
					var device_id = int(data[2])  # Convert device_id to integer
					var sprite = data[3]
					addPlayer(player_counter,device_type,device_id, sprite)
		file.close()  # Close the file after reading

func addPlayer(player_counter: int, device_type: String, device_id: int, sprite: String):

	if(player_counter == 0):
		var player = playerScene.instantiate()
		var remoteTransform := RemoteTransform2D.new()
		
		remoteTransform.remote_path = mainCamera.get_path()
		player.playerController = device_id
		player.playerName = sprite
		player.add_child(remoteTransform)
		
		user_interface.setPlayer(player)
		players.append(player)
		
		mainViewport.add_child(player)
	else:
		var anotherPlayer : Player = playerScene.instantiate()
		var container : SubViewportContainer = SubViewportContainer.new()
		var subViewport = SubViewport.new()
		var playerInterface = UIScene.instantiate()
		var existing_camera = anotherPlayer.find_child("Camera2D", true, false)
		var camera
		if existing_camera:
			camera = existing_camera
		else:
			camera = Camera2D.new()
			camera.set_script(playerCamera)
		# Player Config
		anotherPlayer.playerController = device_id
		anotherPlayer.playerName = sprite
		players.append(anotherPlayer)
		# UI Config
		playerInterface.setPlayer(anotherPlayer)
		# Camera Config

		# SubViewport Config 
		subViewport.world_2d = mainViewport.world_2d
		subViewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		viewports.append(subViewport)
		# Container Config
		container.stretch = true
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Add Children to Scene
		subViewport.add_child(camera)
		subViewport.add_child(playerInterface)
		
		subViewport.add_child(anotherPlayer)		
		container.add_child(subViewport)
		hbox.add_child(container)
		subViewport.get_node("UserInterface/CooldownTimers").set_scale(Vector2(.5, .5))
		subViewport.get_node("UserInterface/PlayerHealthBar").set_scale(Vector2(.9, .9))
		update_grid() 
		# Remote Path to Camera
		var remoteTransform := RemoteTransform2D.new()
		remoteTransform.remote_path = camera.get_path()
		anotherPlayer.add_child(remoteTransform)
		# Spawn new Player into game
		roomGen.spawnPlayer(anotherPlayer, 0)

#func _input(event):
#	if event.is_action_pressed("add_player"):
#		addPlayer()
		

func update_grid():
	var child_count = $HBoxContainer.get_child_count()  # Count number of children

	# Iterate through each child (which are SubViewportContainers)
	for sub_viewport_container in $HBoxContainer.get_children():
		# Ensure this is a SubViewportContainer
		if (sub_viewport_container is SubViewportContainer):
			# Set custom minimum size based on child_count
			if (child_count == 1):
				sub_viewport_container.custom_minimum_size = Vector2(DisplayServer.window_get_size())  # Full size
				set_zoom(3)
			elif (child_count == 2):
				$HBoxContainer.set_columns(2)
				user_interface.get_node("CooldownTimers").set_scale(Vector2(.4,.4))
				user_interface.get_node("PlayerHealthBar").set_scale(Vector2(.9,.9))
				sub_viewport_container.custom_minimum_size = Vector2(DisplayServer.window_get_size().x / 2, DisplayServer.window_get_size().y)
				set_zoom(2.5)
			elif (child_count == 3 || child_count == 4):
				sub_viewport_container.custom_minimum_size = Vector2(DisplayServer.window_get_size().x / 2, DisplayServer.window_get_size().y / 2)
				set_zoom(1.5)
			elif (child_count == 5 || child_count == 6):
				sub_viewport_container.custom_minimum_size = Vector2(DisplayServer.window_get_size().x / 2, DisplayServer.window_get_size().y / 3)
			elif (child_count == 7 || child_count == 8):
				$HBoxContainer.set_columns(3)
				sub_viewport_container.custom_minimum_size = Vector2(DisplayServer.window_get_size().x / 3, DisplayServer.window_get_size().y / 3)

func set_zoom(multiplier: float):
	for player in players:
		print(player.playerName)
		print(player.get_parent().get_children())
		var camera = player.get_parent().find_child("Camera2D", true, false)
		if camera is PlayerCamera:
			print(camera)
			camera.cameraMultiplier = multiplier

func _process(delta):
	# Set Hbox to screensize
	hbox.size = DisplayServer.window_get_size()
	user_interface.level = level
	var enemyCount = enemiesNode.get_child_count()
	
	if(enemyCount == 0 && canChangeLevel):
		canChangeLevel = false
		level_cleared()
		
	if Input.is_action_just_pressed("Menu"):
		settings_menu.visible = true
		get_tree().paused = true
		await get_tree().process_frame  # Ensures UI updates before setting focus

		var close_button = $SettingsMenu/MarginContainer2/MarginContainer/VBoxContainer/GridContainer/CloseButton
		close_button.grab_focus()

var dead_players = 0

func _on_player_death(player):

	if(player in enemies):
		player.queue_free()
		enemies.erase(player)
	else:
		var index = players.find(player)
		var UI = viewports[index].get_node("UserInterface")
		var respawn = UI.get_node("Respawn")
		respawn.visible = true
		player.disable_input()
		dead_players += 1
	
	if dead_players == players.size():
		game_over()

		
func ToGameOver():
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func game_over():
	call_deferred("ToGameOver")	
	
func _on_level_generated():
	if(players.size() == 0):
		if FileAccess.file_exists(player_save):
			read_player_data()
		else: 
			load_all_players()
		roomGen.players = players

	if(level % GlobalVariables.enemyFloorRate == 0):
		var room = roomGen.getRooms().filter(func(room): return room.name == "BossRoom").front()
		if(room):
			var roomMarker = room.find_child("BossStartingPosition") as Marker2D
			var boss = preload("res://Scenes/Enemies/Bosses/Boss.tscn").instantiate()
			enemiesNode.add_child(boss)
			roomGen.spawnEnemy(boss, "", roomMarker.global_position)
	else:
		# Spawn Enemies
		for room in roomGen.getRooms():
			#Do not spawn enemies in the Starting Room
			if(room == roomGen.startRoom):
				continue;
			
			var collisionShape : CollisionShape2D = room.get_node("CollisionShape2D") as CollisionShape2D
			var roomRect = collisionShape.shape.get_rect()
			var numEnemies = randi() % maxEnemiesPerRoom + 1
			
			for i in range(0, numEnemies):
				var enemyObject = enemyScene.instantiate()
				
				enemiesNode.add_child(enemyObject)
				roomGen.spawnEnemy(enemyObject, room)
		
		roomGen.spawnEntities(players)
	canChangeLevel = true
	GlobalVariables.allowDamageFromFloors = true
	
	call_deferred("fadeOut")
	
func fadeOut():
	var tween = create_tween()
	tween.tween_property(fade, 'modulate:a', 0, 5)
	
	
func fadeIn():
	# Fade Black
	var tween = create_tween()
	tween.tween_property(fade, 'modulate:a', 1, 0.25)
	
func level_cleared():
	call_deferred("fadeIn")
	
	GlobalVariables.allowDamageFromFloors = false
	# Pick Upgrade
	upgradeSelectScreen = upgradeSelectionScreen.instantiate()
	upgradeSelectScreen.connect("endSelection", onUpgradeSelected)
	
	#stop the shooting and abilities on upgrade screen
	for player in players:
		player.disable_input()

	# Remove any existing bullets
	var bullets = get_tree().root.find_children("*", "Bullet", true, false)

	for bullet in bullets:
		bullet.queue_free()
		
	#remove all pickups
	for child in $HBoxContainer/SubViewportContainer/SubViewport.get_children():
		if child is Consumable:
			child.queue_free()
		
	
	# Start Upgrade Process
	var baseUpgrades : Array[Node] = players[0].find_children("*", "UpgradeStrategy")
	var selectedUpgrades : Array[UpgradeStrategy]  = []
	
	while(selectedUpgrades.size() != clampf(players.size(), 3, players.size() + 1)):
		var randomUpgrade = randf_range(0, baseUpgrades.size())
		selectedUpgrades.append(baseUpgrades.pop_at(randomUpgrade))
			
	upgradeSelectScreen.upgrades = selectedUpgrades
	add_child(upgradeSelectScreen)

	
func onUpgradeSelected():
	upgradeSelectedCount = upgradeSelectedCount + 1
	
	if(upgradeSelectedCount == players.size()):
		# If UpgradeSelectScreen exists, remove it from tree and set it to null (for next level)
		if(upgradeSelectScreen):
			upgradeSelectScreen.call_deferred("queue_free")
			upgradeSelectScreen = null
			
			# Make al players "Alive" again
			var index = 0
			for player in players:				
				var UI = viewports[index].get_node("UserInterface")
				var respawn = UI.get_node("Respawn")
				respawn.visible = false
				player.position = Vector2(0,0)
				player.visible = true
				index += 1
				player.enable_input()
							
		# Increase Level
		level = level + 1
		
		var file = FileAccess.open(room_save, FileAccess.WRITE)
		file.store_var(level)
		save_all_players()
		upgradeSelectedCount = 0
		#Create Map
		dead_players = 0
		roomGen.moveToNextLevel(level)
	else:
		var currentPlayer = players[upgradeSelectedCount]
		var oldUpgrades = upgradeSelectScreen.upgrades
		var newPlayerUpgrades : Array[UpgradeStrategy] = []
		
		for i in oldUpgrades:
			var currentPlayerUpgrades = currentPlayer.find_children("*", "UpgradeStrategy")
			for j in currentPlayerUpgrades:
				if(j.upgradeId == i.upgradeId):
					newPlayerUpgrades.append(j)
		
		upgradeSelectScreen.upgrades = newPlayerUpgrades
		upgradeSelectScreen.currentPlayerNumber = upgradeSelectedCount + 1
	
