extends Node

var enemyFloorRate = 5
var allowDamageFromFloors = true
# ints 0-3 
var colourBlind = 0

func getMaxEnemiesByLevel(level: float):
	var playerCount = get_tree().root.find_children("*", "Player", true, false).size()
	if(level < 5):
		return 3 + playerCount
	elif(level < 10):
		return 4 + playerCount
	elif(level < 15):
		return 5 + playerCount
	else:
		return 5 + ceil(level / 15) + playerCount
				
func getMinMaxFloorsByLevel(level: float):
	var playerCount = get_tree().root.find_children("*", "Player", true, false).size()
	
	if(level < 5):
		return [2 + playerCount, 3 + playerCount]
	elif(level < 10):
		return [2 + playerCount,5 + playerCount]
	elif(level < 15):
		return [3 + playerCount,5 + playerCount]
	else:
		return [3 + ceil(level / 15) + playerCount, 5 + ceil(level / 15) + playerCount]
		
