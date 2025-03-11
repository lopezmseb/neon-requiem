extends Node
class_name ColorComponent
	
@export var color: String = COLORS.DEFENSIVE 

func _init(new_color: String = COLORS.DEFENSIVE):
	color = new_color

func updateColor(new_color: String):
	color = new_color
	
func getColor():
	return color
