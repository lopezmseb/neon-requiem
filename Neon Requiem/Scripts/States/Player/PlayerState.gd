extends State
class_name PlayerState

var AvailableStates: Dictionary = {
	Movement = "movement",
	Idle = "idle",
	Attack = "attack",
	Dash = "dash"
}

@export var player: CharacterBody2D
@export var speed = 100
@export var animatedSprite: AnimatedSprite2D

func _ready():
	pass # Replace with function body.
