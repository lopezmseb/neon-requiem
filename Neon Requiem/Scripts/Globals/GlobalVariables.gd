extends Node

var enemyFloorRate = 5
var allowDamageFromFloors = true

func getMaxEnemiesByLevel(level: float):
	if(level < 5):
		return 3
	elif(level < 10):
		return 4
	elif(level < 15):
		return 5
	else:
		return 5 + ceil(level / 15)
				
func getMinMaxFloorsByLevel(level: float):
	if(level < 5):
		return [2, 3]
	elif(level < 10):
		return [2,5]
	elif(level < 15):
		return [3,5]
	else:
		return [3 + ceil(level / 15), 5 + ceil(level / 15)]
		
