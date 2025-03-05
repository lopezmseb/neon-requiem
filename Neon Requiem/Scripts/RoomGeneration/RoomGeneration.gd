extends Node2D
class_name RoomGeneration

# Members
# Exported
@export var debugEnabled: bool = false #Debug Only
@export var player: Player = null
@onready var tileMap = $TileMap

var Room = preload("res://Scenes/Room.tscn")
var tileSize = 16
var maxRooms = 10
var minRooms = 5
var minSize = 10
var maxSize = 15
var spread = 200
var roomPositions = []
var path 
var startRoom
var endRoom

signal level_generated
signal level_cleared

const CULL = 0.5

func _ready():
	randomize()
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
	queue_redraw()
	
func moveToNextLevel(level:int):
	# Delete All Old Rooms
	for i in $Rooms.get_children():
		i.queue_free()
	
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
			tileMap.set_cell(0, Vector2i(x, y), 1, Vector2i(5,0), 0)

			
	var connections = []
	for room in $Rooms.get_children():
		var s = (room.size/tileSize).floor()
		var pos = tileMap.local_to_map(room.position)
		var ul = (room.position/tileSize).floor() - s
		
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				var wallPosition = Vector2i(ul.x + x, ul.y + y)  # Convert local position to global tile coordinates
				var chance_10 = randf_range(0.0, 1.0) < 0.13  # 10% chance
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
					tileMap.set_cell(0, wallPosition, 1, Vector2i(0, 1), 0)

		
		var p = path.get_closest_point(room.position)
		
		var pointConnections = path.get_point_connections(p)
		for conn in pointConnections:
			if not conn in connections:
				var start = tileMap.local_to_map(path.get_point_position(p))
				var end = tileMap.local_to_map(path.get_point_position(conn))
				
				var roomNum = room.get_children()
				carvePath(start,end)
				
			connections.append(p)
	
	find_start_room()
	find_end_room()
	clean_up()
	
	
	if(debugEnabled):
		var startText = Label.new()
		startText.text = "Start"
		startRoom.add_child(startText)
		
		var endText = Label.new()
		endText.text = "End"
		endRoom.add_child(endText)

	# Emit signal
	level_generated.emit()
var corners = [
	{
		"pattern":[
			Vector2i(0, 1), Vector2i(0, 0), Vector2i(5, 0),
			Vector2i(0, 1), Vector2i(0, 0), Vector2i(0, 0),
			Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, 1)
		],
		"tile": 0
	},
	{
		"pattern":[
			Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, 1),
			Vector2i(0, 1), Vector2i(0, 0), Vector2i(0, 0),
			Vector2i(0, 1), Vector2i(0, 0), Vector2i(5, 0)
		],
		"tile": 1
	},
	{
		"pattern":[
			Vector2i(5, 0), Vector2i(0, 0), Vector2i(0, 1),
			Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 1),
			Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, 1)
		],
		"tile": 2
	},
	{
		"pattern":[
			Vector2i(0, 1), Vector2i(0, 1), Vector2i(0, 1),
			Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 1),
			Vector2i(5, 0), Vector2i(0, 0), Vector2i(0, 1)
		],
		"tile": 3
	},
	
]

func findCorner(position: Vector2i):
	var surrounding_cells = tileMap.get_surrounding_cells(position)
	# Iterate through each pattern to check if it matches
	for pattern_info in corners:
		var target_pattern = pattern_info["pattern"]
		var matching_tile = pattern_info["tile"]
		
		# Check if the surrounding tiles match the pattern
		var pattern_match = true
		var pattern_length = len(target_pattern)

		# Check if the surrounding cells match the pattern
		for i in range(pattern_length):
			if i >= surrounding_cells.size():
				pattern_match = false
				break  # Stop checking if the pattern is broken
			var cell_pos = surrounding_cells[i]
			var current_tile = tileMap.get_cell_atlas_coords(0, cell_pos)
			if current_tile != target_pattern[i]:
				pattern_match = false
				break  # Stop checking if the pattern is broken

		# If the pattern matches, place the corresponding tile
		if pattern_match:
			print("MATCH FOUND")
			tileMap.set_cell(0, position, 1, Vector2i(4, 0), 0)
			break  # Stop checking other patterns once a match is found

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

	tileMap.set_cell(0, pos1, 1, Vector2i(4, 1))
	tileMap.set_cell(0, pos2, 1, Vector2i(4, 1))
#	if randi() % 2 > 0:
#		x_y = pos2
#		y_x = pos1

	# Carve horizontal path
	for x in range(pos1.x, pos2.x, xDiff):
	# Set the main tile
		tileMap.set_cell(0, Vector2i(x, x_y.y), 1, Vector2i(0, 1))
		tileMap.erase_cell(1, Vector2i(x, x_y.y))
#		if x >= pos2.x:
#			tileMap.set_cell(0, Vector2i(x + 1, x_y.y), 1, Vector2i(4, 1),0)
#			tileMap.set_cell(0, Vector2i(x + 1, x_y.y + xDiff ), 1, Vector2i(4, 1),0)
#		if x == pos1.x:
#			tileMap.set_cell(0, Vector2i(x - 1, x_y.y), 1, Vector2i(4, 1),0)
#			tileMap.set_cell(0, Vector2i(x - 1, x_y.y - xDiff ), 1, Vector2i(4, 1),0)

		
		# Check if the tile at the left of the current position is the target tile (5, 0)
		var left_pos = Vector2i(x - 1, x_y.y)
		if tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, left_pos, 1, Vector2i(0, 0))
			

		var top_pos : Vector2i
		var bottom_pos : Vector2i
		if xDiff > 0:
			top_pos = Vector2i(x, x_y.y - 1)
			bottom_pos = Vector2i(x, x_y.y + 2)
		elif xDiff < 0:
			top_pos = Vector2i(x, x_y.y - 2)
			bottom_pos = Vector2i(x, x_y.y + 1)

		# Check top and bottom positions for the target tile (5, 0)
		if tileMap.get_cell_atlas_coords(0, top_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, top_pos, 1, Vector2i(0, 0))
			
		
		if tileMap.get_cell_atlas_coords(0, bottom_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, bottom_pos, 1, Vector2i(0, 0), 2)
			
		
		# Set the final tile at the position with xDiff applied
		tileMap.set_cell(0, Vector2i(x, x_y.y + xDiff), 1, Vector2i(0, 1))
		tileMap.erase_cell(1, Vector2i(x, x_y.y + xDiff))


	# Carve vertical path
	# Carve vertical path
	for y in range(pos1.y, pos2.y, yDiff):
		# Set the main tile
		tileMap.set_cell(0, Vector2i(y_x.x, y), 1, Vector2i(0, 1))
		tileMap.erase_cell(1, Vector2i(y_x.x, y))

		# Check if the tile above the current position is the target tile (5, 0)
		var above_pos = Vector2i(y_x.x, y - 1)
		if tileMap.get_cell_atlas_coords(0, above_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, above_pos, 1, Vector2i(0, 0), 1)
			

		# Handle different yDiff values
		var left_pos : Vector2i
		var right_pos : Vector2i
		if yDiff > 0:
			left_pos = Vector2i(y_x.x - 1, y)
			right_pos = Vector2i(y_x.x + 2, y)
		elif yDiff < 0:
			left_pos = Vector2i(y_x.x - 2, y)
			right_pos = Vector2i(y_x.x + 1, y)

		# Check left and right positions for the target tile (5, 0)
		if tileMap.get_cell_atlas_coords(0, left_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, left_pos, 1, Vector2i(0, 0), 1)
			
		if tileMap.get_cell_atlas_coords(0, right_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, right_pos, 1, Vector2i(0, 0), 3)
			

		# Set the final tile with yDiff applied
		tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y), 1, Vector2i(0, 1))
		tileMap.erase_cell(1, Vector2i(y_x.x + yDiff, y))

		# Check if the tile above the final position is the target tile (5, 0)
		if tileMap.get_cell_atlas_coords(0, above_pos) == Vector2i(5, 0):
			tileMap.set_cell(0, Vector2i(y_x.x + yDiff, y - 1), 1, Vector2i(0, 0), 1)
			
		# Call findCorner for the current position
		



		
func clean_up():
	var fullRectangle = Rect2()
	var topLeft = tileMap.local_to_map(fullRectangle.position)
	var bottomRight = tileMap.local_to_map(fullRectangle.end)
		
	for x in range (topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			findCorner(Vector2i(x, y))


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
