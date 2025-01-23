extends Node2D
var Room = preload("res://Scenes/Room.tscn")

# Members
@export var debugEnabled: bool = false #Debug Only
@onready var tileMap = $TileMap
@onready var fade : ColorRect = $UserInterface.find_child("Fade")
var player = preload("res://Scenes/Player.tscn")
var enemy = preload("res://Scenes/BaseEnemy.tscn")
var playerObject : CharacterBody2D
var tileSize = 16
var maxRooms = 15
var minRooms = 10
var maxEnemiesPerRoom = 5
var minSize = 10
var maxSize = 15
var spread = 200
var roomPositions = []
var level: int = 1
var canChangeLevel : bool = false
var path 
var startRoom
var endRoom

const CULL = 0.5

func _ready():
	randomize()
	makeRooms()
	
func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		var camera:Camera2D = $Player.find_child("Camera2D")
		camera.enabled = !camera.enabled
		debugEnabled = !debugEnabled
	
# Generates A Random Number of Rooms into the scene
func makeRooms():
	# Generates between minRooms and maxRooms number of rooms  
	for i in range(randf_range(minRooms, maxRooms)):
		var pos = Vector2(randf_range(-spread, spread),randf_range(-spread, spread))
		var r = Room.instantiate()
		var w = minSize + randi() % (maxSize - minSize)
		var h = minSize + randi() % (maxSize - minSize) 
		
		r.makeRoom(pos, Vector2(w,h) * tileSize)
		$Rooms.add_child(r)
		
		if(debugEnabled):
			var roomNumber: Label = Label.new()
			roomNumber.text = "{room}".format({"room": i})
			r.add_child(roomNumber)
	
	# Wait for Rooms to Finish Moving
	$RoomMovementWait.start()
		
	
func _process(delta):
	
	$DebugCamera.enabled = debugEnabled
	
	var enemyCount = $Enemies.get_children().size()
	print("Enemy Count: {count}".format({"count" : enemyCount}))
	
	if(enemyCount == 0 && canChangeLevel):
		canChangeLevel = false
		level = level + 1
		$UserInterface.levelCount = level
		fade.visible = true
		makeMap()
	
	queue_redraw()
	
func spawnEntities():
	if(!playerObject):
		# Spawn Player
		playerObject = player.instantiate()
		
		add_child(playerObject)
	playerObject.position = startRoom.position
	
	# Spawn Enemies
	for room in $Rooms.get_children():
		#Do not spawn enemies in the Starting Room
		if(room == startRoom):
			continue;
		
		var collisionShape : CollisionShape2D = room.get_node("CollisionShape2D") as CollisionShape2D
		var roomRect = collisionShape.shape.get_rect()
		var numEnemies = randi() % maxEnemiesPerRoom
		
		for i in range(0, numEnemies):
			var enemyObject = enemy.instantiate()
			
			$Enemies.add_child(enemyObject)
			enemyObject.position = room.position
	
	canChangeLevel = true
	fade.visible = false

# On RoomMovementWait 
func _on_room_movement_wait_timeout():
	var roomCount = $Rooms.get_children().size()
	
	for room in $Rooms.get_children():
		# If Room Count is the same as minRooms, stop culling
		# Cull Room if randf is less than cull (should cull a percentage of rooms)
		if(randf() < CULL && roomCount != minRooms ):
			room.queue_free()
			roomCount -= 1
		# Stop Rooms from moving
		else:
			room.freeze = true
			room.find_child("CollisionShape2D").disabled = true
			roomPositions.append(room.position)
	# Wait for all rooms to be set to static
	await get_tree().process_frame
	path = find_mst(roomPositions)
	# Draw the Map
	await get_tree().process_frame
	makeMap()
	
func find_mst(nodes: Array):
	#Prim's algorithm
	path = AStar2D.new()

	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	#repeat until no more node remains
	while nodes:
		var minD = INF #minimum distance so far
		var minP = null #position of that node
		var p = null #current position
		#loop through all points in the path
		for p1 in path.get_point_ids():
			var p3
			p3 = path.get_point_position(p1)
			#loop though the remaining nodes
			for p2 in nodes:
				if p3.distance_to(p2) < minD:
					minD = p3.distance_to(p2)
					minP = p2
					p = p3
		var n = path.get_available_point_id()
		path.add_point(n, minP)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(minP)
	return path
			
func makeMap():
	# Create a Tile Map for generated rooms and path
	tileMap.clear()
	
	var fullRectangle = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position - room.size, 
			room.get_node("CollisionShape2D").shape.extents*2)
		fullRectangle = fullRectangle.merge(r)
		
	var topLeft = tileMap.local_to_map(fullRectangle.position)
	var bottomRight = tileMap.local_to_map(fullRectangle.end)
		
	for x in range (topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			tileMap.set_cell(0, Vector2i(x, y), 1, Vector2i(0,0), 0)

			
	var connections = []
	for room in $Rooms.get_children():
		var s = (room.size/tileSize).floor()
		var pos = tileMap.local_to_map(room.position)
		var ul = (room.position/tileSize).floor() - s
		
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				tileMap.set_cell(0, Vector2i(ul.x + x, ul.y + y), 1, Vector2i(0, 1), 0)
		
		var p = path.get_closest_point(room.position)
		
		var pointConnections = path.get_point_connections(p)
		for conn in pointConnections:
			if not conn in connections:
				var start = tileMap.local_to_map(path.get_point_position(p))
				var end = tileMap.local_to_map(path.get_point_position(conn))
				
				var roomNum = room.get_children()
				print(roomNum)
				carvePath(start,end)
				
			connections.append(p)
	
	find_start_room()
	find_end_room()
	
	
	if(debugEnabled):
		var startText = Label.new()
		startText.text = "Start"
		startRoom.add_child(startText)
		
		var endText = Label.new()
		endText.text = "End"
		endRoom.add_child(endText)
	

	
	# Spawn Entities
	spawnEntities()

func carvePath(pos1, pos2):
	# Carve path between two points
	var xDiff = sign(pos2.x - pos1.x)
	var yDiff = sign(pos2.y - pos1.y)
	
	if(xDiff == 0):
		xDiff = pow(-1, randi()%2)
	if(yDiff == 0):
		yDiff = pow(-1, randi()%2)
		
	var x_y = pos1
	var y_x = pos2

	if(randi()%2) > 0:
		x_y = pos2
		y_x = pos1
		
	for x in range(pos1.x, pos2.x, xDiff):
		tileMap.set_cell(0, Vector2i(x, x_y.y), 1,Vector2i(0, 1), 0);
		tileMap.set_cell(0, Vector2i(x, x_y.y + xDiff), 1, Vector2i(0, 1), 0);
	for y in range(pos1.y, pos2.y, yDiff):
		tileMap.set_cell(0, Vector2i(y_x.x, y), 1,Vector2i(0, 1), 0);
		tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y), 1, Vector2i(0, 1), 0);

		

func find_start_room():
	var min_x = INF 
	for room in $Rooms.get_children():
		if room.position.x < min_x: 
			startRoom = room
			min_x = room.position.x
func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			endRoom = room
			max_x = room.position.x
