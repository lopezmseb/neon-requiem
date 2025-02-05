extends Control

@onready var playerScene = preload("res://Scenes/Player.tscn")
@onready var hbox = $HBoxContainer
@onready var mainViewport = $HBoxContainer/SubViewportContainer/SubViewport
@onready var mainCamera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D
@onready var roomGen : RoomGeneration = $HBoxContainer/SubViewportContainer/SubViewport/RoomGeneration
@onready var user_interface = $HBoxContainer/SubViewportContainer/SubViewport/UserInterface
@onready var fade = $Fade
@onready var playerCamera = preload("res://Scripts/Player/PlayerCamera.gd")
var players: Array[Player]

func _ready():
	# Set Hbox to screensize
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

		# Player Config
		anotherPlayer.playerController = 0
		players.append(anotherPlayer)
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
		mainViewport.add_child(anotherPlayer)		
		container.add_child(subViewport)
		hbox.add_child(container)
		# Remote Path to Camera
		var remoteTransform := RemoteTransform2D.new()
		remoteTransform.remote_path = camera.get_path()
		anotherPlayer.add_child(remoteTransform)
		# Spawn new Player into game
		roomGen.spawnPlayer(anotherPlayer)
		
	
func _process(delta):
	# Set Hbox to screensize
	hbox.size = DisplayServer.window_get_size()

func _on_level_generated():
	if(players.size() == 0):
		var player = playerScene.instantiate()
		var remoteTransform := RemoteTransform2D.new()
		
		remoteTransform.remote_path = mainCamera.get_path()
		player.add_child(remoteTransform)
		players.append(player)
		
		mainViewport.add_child(player)
	
	roomGen.spawnEntities(players)
	
	var tween = get_tree().create_tween()
	tween.tween_property(fade, 'color:a', 0, 1)
	
	
	
	
