extends Node

@onready var cooldowns: Array[Node] = get_tree().get_nodes_in_group("Cooldown")
var cooldown_UI: Array[RichTextLabel]

func _ready():
	print(cooldowns)
	for i in cooldowns:
		cooldown_UI.append(RichTextLabel.new())


func _process(delta):
	for i in cooldowns:
		var timer := i as Timer
		
		if(timer.is_stopped()):
			# Set Text Node to Active or Empty or Something
			print("Active")
		else:
			# Set Text Node to Time Left
			print(timer.time_left)
	
	
