extends Node2D
@onready var tileMap: TileMap = $TileMap

var players = []

func _process(delta: float) -> void:
	if(players.size() == 0):
		players = get_tree().root.find_children("*", "Player", true, false)
	else:
		tileDamage()
		

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
	
