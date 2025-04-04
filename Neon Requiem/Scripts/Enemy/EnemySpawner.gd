extends Node
class_name EnemySpawner

const shootingEnemyScene: PackedScene = preload("res://Scenes/BaseEnemy.tscn")
const bladedEnemyScene: PackedScene = preload("res://Scenes/SwordEnemy.tscn")
const enemyScenes = [shootingEnemyScene, bladedEnemyScene]

func spawnEnemies(numberOfEnemies: float):
	var enemyObjects = []

	for i in range(numberOfEnemies):
		var newEnemyScene = enemyScenes.pick_random()
		enemyObjects.append(newEnemyScene.instantiate())
	
	return enemyObjects
