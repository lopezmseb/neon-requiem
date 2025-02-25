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
var save_path = "user://room.save"
var level: int = 1
var canChangeLevel : bool = false
var maxEnemiesPerRoom = 5
var players: Array[Player]
var enemies: Array[Node]

func _ready():
	# Set Hbox to screensize
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ) 
		level = file.get_var(level)
		
	hbox.size = DisplayServer.window_get_size()
	# Set Pixel Style
	var subviewports = find_children("SubViewport")
	
	for i in subviewports:
		var subviewport = i as SubViewport
		
		if(subviewport):
			subviewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
			subviewport.world_2d = mainViewport.world_2d

func _input(event):
	if event.is_action_pressed("add_player"):
		var anotherPlayer : Player = playerScene.instantiate()
		var container : SubViewportContainer = SubViewportContainer.new()
		var subViewport = SubViewport.new()
		var camera = Camera2D.new()
		var playerInterface = UIScene.instantiate()

		# Player Config
		anotherPlayer.playerController = 0
		players.append(anotherPlayer)
		# UI Config
		playerInterface.setPlayer(anotherPlayer)
		# Camera Config
		camera.set_script(playerCamera)
		# SubViewport Config 
		subViewport.world_2d = mainViewport.world_2d
		subViewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		# Container Config
		container.stretch = true
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Add Children to Scene
		subViewport.add_child(camera)
		subViewport.add_child(playerInterface)
		mainViewport.add_child(anotherPlayer)		
		container.add_child(subViewport)
		hbox.add_child(container)
		# Remote Path to Camera
		var remoteTransform := RemoteTransform2D.new()
		remoteTransform.remote_path = camera.get_path()
		anotherPlayer.add_child(remoteTransform)
		# Spawn new Player into game
		roomGen.spawnPlayer(anotherPlayer, 0)
		
	
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


func _on_level_generated():
	if(players.size() == 0):
		var player = playerScene.instantiate()
		var remoteTransform := RemoteTransform2D.new()
		
		remoteTransform.remote_path = mainCamera.get_path()
		player.add_child(remoteTransform)
		
		user_interface.setPlayer(player)
		players.append(player)
		
		mainViewport.add_child(player)
	
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
	var tween = get_tree().create_tween()
	tween.tween_property(fade, 'color:a', 0, 1)
	
func level_cleared():
	print("Level Cleared")
	# Pick Upgrade
	
	# Fade Black
	var tween = get_tree().create_tween()
	tween.tween_property(fade, 'color:a', 1, 0.25)
	
	# Increase Level
	level = level + 1
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(level)
	#Create Map
	roomGen.moveToNextLevel(level)
	
	
	
	
