extends State
class_name EnemyState

var AvailableStates: Dictionary = {
	Idle = "idle",
	Follow = "follow"
}

@export var enemy: CharacterBody2D
@export var speed = 50

var player: CharacterBody2D

func _ready():
	#Note: This code will probably fail when multiplayer starts :(
	player = get_tree().get_first_node_in_group("Player")


