extends Node

@export var spawnArea: CollisionShape2D
@export var numOfEnemies: int = 4


const enemyScene: PackedScene = preload("res://Scenes/BaseEnemy.tscn")

func _ready():
	var origin = spawnArea.get_transform().get_origin()
	var size = spawnArea.shape.extents * 2
	
	for i in range(0, numOfEnemies):
		var instance: CharacterBody2D = enemyScene.instantiate()
		
		var randomPositionX = randf_range(origin.x, origin.x + size.x)
		var randomPositionY = randf_range(origin.y, origin.y + size.y)
		instance.position = Vector2(randomPositionX, randomPositionY)
		
		add_child(instance)
		
	
