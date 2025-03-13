extends State
class_name EnemyState

var AvailableStates: Dictionary = {
	Idle = "idle",
	Follow = "follow",
	Attack = "attack",
	Death = "death"
}

@export var enemy: CharacterBody2D
@export var speed = 50
@export var animate: AnimatedSprite2D

var player: CharacterBody2D = null
