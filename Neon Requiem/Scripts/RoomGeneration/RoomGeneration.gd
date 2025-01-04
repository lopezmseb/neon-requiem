extends Node2D
var Room = preload("res://Scenes/Room.tscn")

# Members
var tileSize = 32
var maxRooms = 30
var minRooms = 10
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
	#Prim's algorithm
	path = AStar2D.new()
	# TODO: Figure out why it crashes here sometimes lol
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
			
