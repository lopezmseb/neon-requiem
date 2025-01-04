extends Node2D
var Room = preload("res://Scenes/Room.tscn")

# Members
var tileSize = 32
var maxRooms = 30
var minRooms = 20
var minSize = 4
var maxSize = 10
var spread = 400
var roomPositions = []
var path 

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
	
	# Wait for Rooms to Finish Moving
	$RoomMovementWait.start()
		
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(32,228,0), false)
	
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(pp,cp, Color(1, 0.5, 0))

func _process(delta):
	queue_redraw()
	
# Test Feature: Remove on release	
func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		makeRooms()

# On RoomMovementWait 
func _on_room_movement_wait_timeout():
	var roomCount = $Rooms.get_children().size()
	
	for room in $Rooms.get_children():
		# If Room Count is the same as minRooms, stop culling
		if(roomCount == minRooms):
			break
		# Cull Room if randf is less than cull (should cull a percentage of rooms)
		elif(randf() < CULL ):
			room.queue_free()
			roomCount -= 1
		# Stop Rooms from moving
		else:
			room.freeze = true
			roomPositions.append(room.position)
	# Wait for all rooms to be set to static
	$MSTStart.start()


func _on_mst_start_timeout():
	path = find_mst(roomPositions)
	
func find_mst(nodes: Array):
	# Implementing Prim's Algorithm
	var aStar = AStar2D.new()
	print(aStar)
	aStar.add_point(aStar.get_available_point_id(), nodes.pop_front())
	
	# Repeat until all nodes are gone
	while nodes:
		# Infinity is the minimum distance 
		var min_dist = INF 
		var minPosition = null # Position of Node
		var currentPosition= null # Current Position
		
		for positionId in aStar.get_point_ids():
			var positionOfNode = aStar.get_point_position(positionId)
			# Loop through rest of nodes
			for otherId in nodes:
				if(positionOfNode.distance_to(otherId) < min_dist):
					min_dist = positionOfNode.distance_to(otherId)
					minPosition = otherId
					currentPosition = positionOfNode
					
		var n = aStar.get_available_point_id()
		aStar.add_point(n,minPosition)
		aStar.connect_points(aStar.get_closest_point(currentPosition), n)
		nodes.erase(minPosition)
	
	return aStar
			
