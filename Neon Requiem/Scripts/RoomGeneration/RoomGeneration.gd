extends Node2D
class_name RoomGeneration

# Members
# Exported
@export var debugEnabled: bool = false #Debug Only
@export var player: Player = null
@onready var tileMap = $TileMap

var Room = preload("res://Scenes/Room.tscn")
var tileSize = 16
var maxRooms = 3
var minRooms = 2
var minSize = 10
var maxSize = 12
var spread = 200
var roomPositions = []
var path
var startRoom
var endRoom
var players = []

signal level_generated
signal level_cleared

const CULL = 0.5
const COLOR_ROOM_FREQUENCY = 0.25


func _ready():
	randomize()
	GlobalSignals.onColorChange.connect(changeColors)
	makeRooms()
	
	
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
	
func getRooms():
	return $Rooms.get_children()
		
	
func _process(delta):
	for player in players:
		if(player is Player):
			var tilePosition = tileMap.local_to_map(to_local(player.global_position))
			var atlasCoords = tileMap.get_cell_atlas_coords(2, tilePosition)
			
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
	
	queue_redraw()
	
func moveToNextLevel(level:int):
	# Delete All Old Rooms
	for i in $Rooms.get_children():
		i.queue_free()
		
	tileMap.clear()
	
	makeRooms()
	
func spawnPlayer(player: Player, offset: float):
	if(is_instance_valid(startRoom)):
		player.position = Vector2(startRoom.position.x + offset, startRoom.position.y)
	
func spawnEnemy(enemy, room):
	enemy.position = room.position
	
func spawnEntities(players: Array[Player]) -> void:
	# Set Player to startRoom position
	var count = 0
	for player in players:
		find_start_room()
		spawnPlayer(player, count * 50 )
		count = count + 1

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
		print("IN NODE LOOP")
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
	
func _input(event):
	if(Input.is_key_pressed(KEY_DELETE)):
		moveToNextLevel(1)
	
	if(Input.is_key_pressed(KEY_INSERT)):
		changeColors()
			
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
			tileMap.set_cell(0, Vector2i(x, y), 1, Vector2i(5,0), 0)

			
	var connections = []
	find_start_room()
	find_end_room()
	for room in $Rooms.get_children():
		var s = (room.size/tileSize).floor()
		var pos = tileMap.local_to_map(room.position)
		var ul = (room.position/tileSize).floor() - s
		
		# If ColorVariability is less than 0.1 then this room is a ColorRoom (10% of rooms will be ColorRooms)
		var colorVariability = randf_range(0,1)
		var isColorRoom = colorVariability < COLOR_ROOM_FREQUENCY
		var crissCross = randf_range(0,1) if isColorRoom else 1
		
		var sizeX = s.x * 2 - 1
		var sizeY = s.y * 2 - 1
		for x in range(2, sizeX):
			for y in range(2,sizeY):
				var wallPosition = Vector2i(ul.x + x, ul.y + y)  # Convert local position to global tile coordinates
				var chance_10 = randf_range(0.0, 1.0) < 0.13  # 13% chance
				var chace_25 = randi() % 4 # 25% chance
				
		
				# Check for corners first
				if x == 2 and y == 2:  # Top-left corner
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(4, 0), 2)
				elif x == s.x * 2 - 2 and y == 2:  # Top-right corner
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(4, 0), 0)
				elif x == 2 and y == s.y * 2 - 2:  # Bottom-left corner
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(4, 0), 1)
				elif x == s.x * 2 - 2 and y == s.y * 2 - 2:  # Bottom-right corner
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(4, 0), 3)

				# Set normal edges
				elif x == 2:  # Left edge (270° rotation)
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(0, 0), 1)
						if chance_10:
							tileMap.set_cell(1, Vector2i(wallPosition.x + 1, wallPosition.y), 1, Vector2i(chace_25, 4),1)
				elif x == s.x * 2 - 2:  # Right edge (90° rotation)
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(0, 0), 3)
						if chance_10:
							tileMap.set_cell(1, Vector2i(wallPosition.x - 1, wallPosition.y), 1, Vector2i(chace_25, 4),3)
				elif y == 2:  # Top edge (0° rotation)
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(0, 0), 0)
						if chance_10:
							tileMap.set_cell(1, Vector2i(wallPosition.x, wallPosition.y + 1), 1, Vector2i(chace_25, 4),0)
				elif y == s.y * 2 - 2:  # Bottom edge (180° rotation)
					if tileMap.get_cell_atlas_coords(0, wallPosition) == Vector2i(5, 0):
						tileMap.set_cell(0, wallPosition, 1, Vector2i(0, 0), 2)
						if chance_10:
							tileMap.set_cell(1, Vector2i(wallPosition.x , wallPosition.y - 1), 1, Vector2i(chace_25, 4),2)
				else:
					var floorTile = Vector2i(0,1)
					var offset = 7
					var sizeOffset = offset -1
					if(isColorRoom && room != startRoom):
						floorTile = Vector2i(4,1) if colorVariability < COLOR_ROOM_FREQUENCY/2 else Vector2i(4,3)
						# Our checks later are reliant on layer 0, so we just put layer 2 above
						# that layer (z-index wise)
						var oppositeFloorTile = Vector2i(4,3) if colorVariability < COLOR_ROOM_FREQUENCY/2 else Vector2i(4,1)
						if((y > offset and y < sizeY-sizeOffset) or (x > offset and x < sizeX-sizeOffset)):
							tileMap.set_cell(2, wallPosition, 1, floorTile, 0)
						elif(crissCross < 0.15):
							tileMap.set_cell(2, wallPosition, 1, oppositeFloorTile, 0)
					tileMap.set_cell(0, wallPosition, 1, Vector2i(0,1), 0)
					
		
		var p = path.get_closest_point(room.position)
		
		var pointConnections = path.get_point_connections(p)
		for conn in pointConnections:
			if not conn in connections:
				var start = tileMap.local_to_map(path.get_point_position(p))
				var end = tileMap.local_to_map(path.get_point_position(conn))
				
				var roomNum = room.get_children()
				carvePath(start,end)
				
			connections.append(p)
	

	
	
	if(debugEnabled):
		var startText = Label.new()
		startText.text = "Start"
		startRoom.add_child(startText)
		
		var endText = Label.new()
		endText.text = "End"
		endRoom.add_child(endText)

	# Emit signal
	await get_tree().process_frame

	level_generated.emit()
	


func carvePath(pos1: Vector2i, pos2: Vector2i):
	# Determine direction of movement
	var xDiff = sign(pos2.x - pos1.x)
	var yDiff = sign(pos2.y - pos1.y)

	if xDiff == 0:
		xDiff = pow(-1, randi() % 2)
	if yDiff == 0:
		yDiff = pow(-1, randi() % 2)

	var x_y = pos1
	var y_x = pos2
	
	if randi() % 2 > 0:
		x_y = pos2
		y_x = pos1

	# Carve horizontal path
	for x in range(pos1.x, pos2.x, xDiff):
		
		# Handle different yDiff values (direction the path is generated)
		var top_pos : Vector2i
		var bottom_pos : Vector2i
		if xDiff > 0:
			top_pos = Vector2i(x, x_y.y - 1)
			bottom_pos = Vector2i(x, x_y.y + 2)
		elif xDiff < 0:
			top_pos = Vector2i(x, x_y.y - 2)
			bottom_pos = Vector2i(x, x_y.y + 1)
			
		# Set the path tile
		tileMap.set_cell(0, Vector2i(x, x_y.y), 1, Vector2i(0, 1))
		tileMap.set_cell(0, Vector2i(x, x_y.y + xDiff), 1, Vector2i(0, 1))
		
		if  tileMap.get_cell_atlas_coords(0, Vector2i(x + 1,  x_y.y + xDiff)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(x + 1,  x_y.y + xDiff), 1, Vector2i(0,
				0), 3)
		if  tileMap.get_cell_atlas_coords(0, Vector2i(x + 1, x_y.y)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(x + 1, x_y.y), 1, Vector2i(0, 0), 3)
		if  tileMap.get_cell_atlas_coords(0, Vector2i(x - 1,  x_y.y + xDiff)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(x - 1,  x_y.y + xDiff), 1, Vector2i(0, 0), 1)
		if  tileMap.get_cell_atlas_coords(0, Vector2i(x - 1, x_y.y)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(x - 1, x_y.y), 1, Vector2i(0, 0), 1)
		#erase detail tiles on layer 1
		tileMap.erase_cell(1, Vector2i(x, x_y.y + xDiff))
		tileMap.erase_cell(1, Vector2i(x, x_y.y))
		tileMap.erase_cell(1, top_pos)
		tileMap.erase_cell(1, bottom_pos)

		# if prev tile is floor current tile is wall make it a corner
		if tileMap.get_cell_atlas_coords(0, Vector2i(top_pos.x - 1, top_pos.y)) == Vector2i(0, 1) && tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, top_pos, 1, Vector2i(6, 0),1)
		# if next tile is floor current tile is wall make it a corner
		elif tileMap.get_cell_atlas_coords(0, Vector2i(top_pos.x + 1, top_pos.y)) == Vector2i(0, 1) && tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(0, 0) :
			tileMap.set_cell(0, top_pos, 1, Vector2i(6, 0),3)
			
		# if prev tile is floor current tile is wall make it a corner	
		if tileMap.get_cell_atlas_coords(0, Vector2i(bottom_pos.x - 1, bottom_pos.y)) == Vector2i(0, 1) && tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, bottom_pos, 1, Vector2i(6, 0),2)
		# if next tile is floor current tile is wall make it a corner
		elif tileMap.get_cell_atlas_coords(0, Vector2i(bottom_pos.x + 1, bottom_pos.y)) == Vector2i(0, 1) && tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, bottom_pos, 1, Vector2i(6, 0))
		
		# if tiles to top and buttom are black, place regular wall
		if tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(5, 0)|| tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(4, 0):
			tileMap.set_cell(0, bottom_pos, 1, Vector2i(0, 0), 2)
		elif tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(0, 0) && tileMap.get_cell_alternative_tile(0, bottom_pos) != 2:
			tileMap.set_cell(0, bottom_pos, 1, Vector2i(7, 0))
		if tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(5, 0) || tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(4, 0):
			tileMap.set_cell(0, top_pos, 1, Vector2i(0, 0))
		elif tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(0, 0) && tileMap.get_cell_alternative_tile(0, top_pos) != 0:
			tileMap.set_cell(0, top_pos, 1, Vector2i(7, 0))
		
		await get_tree().process_frame

	# Carve vertical path
	for y in range(pos1.y, pos2.y, yDiff):
		# Handle different yDiff values (direction the path is generated)
		var left_pos : Vector2i
		var right_pos : Vector2i
		
		if yDiff > 0:
			left_pos = Vector2i(y_x.x - 1, y)
			right_pos = Vector2i(y_x.x + 2, y)
		elif yDiff < 0:
			left_pos = Vector2i(y_x.x - 2, y)
			right_pos = Vector2i(y_x.x + 1, y)
		# Set the path tile
		tileMap.set_cell(0, Vector2i(y_x.x, y), 1, Vector2i(0, 1))
		tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y), 1, Vector2i(0, 1))
		if  tileMap.get_cell_atlas_coords(0, Vector2i(y_x.x, y + 1)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(y_x.x, y + 1), 1, Vector2i(0, 0), 2)
		if  tileMap.get_cell_atlas_coords(0, Vector2i(y_x.x + yDiff, y + 1)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y + 1), 1, Vector2i(0, 0), 2)
		if  tileMap.get_cell_atlas_coords(0, Vector2i(y_x.x, y - 1)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(y_x.x, y - 1), 1, Vector2i(0, 0))
		if  tileMap.get_cell_atlas_coords(0, Vector2i(y_x.x + yDiff, y - 1)) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y - 1), 1, Vector2i(0, 0))
		# delete any detail tiles on layer 1 
		tileMap.erase_cell(1, Vector2i(y_x.x, y))
		tileMap.erase_cell(1, Vector2i(y_x.x + yDiff, y))
		tileMap.erase_cell(1, left_pos)
		tileMap.erase_cell(1, right_pos)
			
		# if prev tile is floor current tile is wall make it a corner
		if tileMap.get_cell_atlas_coords(0, Vector2i(left_pos.x, left_pos.y - 1)) == Vector2i(0, 1) and tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, left_pos, 1, Vector2i(6 ,0))
		# if next tile is floor current tile is wall make it a corner
		elif tileMap.get_cell_atlas_coords(0, Vector2i(left_pos.x, left_pos.y + 1)) == Vector2i(0, 1) and tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, left_pos, 1, Vector2i(6, 0),3)

		# if prev tile is floor current tile is wall make it a corner
		if tileMap.get_cell_atlas_coords(0, Vector2i(right_pos.x, right_pos.y - 1)) == Vector2i(0, 1) and tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, right_pos, 1, Vector2i(6, 0),2)
		# if next tile is floor current tile is wall make it a corner
		elif tileMap.get_cell_atlas_coords(0, Vector2i(right_pos.x, right_pos.y + 1)) == Vector2i(0, 1) and tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(0, 0):
			tileMap.set_cell(0, right_pos, 1, Vector2i(6, 0),1)
			
		# if tiles to left and right are black, place regular wall
		if tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(5, 0) || tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(4, 0):
			tileMap.set_cell(0, left_pos, 1, Vector2i(0, 0), 1)
		elif tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(0, 0) && tileMap.get_cell_alternative_tile(0, left_pos) != 1:
			tileMap.set_cell(0, left_pos, 1, Vector2i(7, 0))
			
			
		if tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(5, 0) || tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(4, 0):
			tileMap.set_cell(0, right_pos, 1, Vector2i(0, 0), 3)
		elif tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(0, 0)&& tileMap.get_cell_alternative_tile(0, right_pos) != 3:
			tileMap.set_cell(0, right_pos, 1, Vector2i(7, 0))
		await get_tree().process_frame

func changeColors():
	for room in $Rooms.get_children():
		var s = (room.size/tileSize).floor()
		var ul = (room.position/tileSize).floor() - s
		
		var sizeX = s.x * 2 - 1
		var sizeY = s.y * 2 - 1
		for x in range(2, sizeX):
			for y in range(2,sizeY):
				var wallPosition = Vector2i(ul.x + x, ul.y + y)
				
				if(tileMap.get_cell_atlas_coords(2, wallPosition) == Vector2i(-1,-1)):
					continue
				
				if(tileMap.get_cell_atlas_coords(2, wallPosition) == Vector2i(4,1)):
					tileMap.erase_cell(2, wallPosition)
					tileMap.set_cell(2, wallPosition, 1, Vector2(4,3))
				elif(tileMap.get_cell_atlas_coords(2, wallPosition) == Vector2i(4,3)):
					tileMap.erase_cell(2, wallPosition)
					tileMap.set_cell(2, wallPosition, 1, Vector2(4,1))
			

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
