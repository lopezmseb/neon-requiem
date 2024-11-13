extends Node2D

@onready var entrance: Node2D = $Entrance
@onready var enemies: Node2D = $Enemies
@onready var doors: Node2D = $Doors
@onready var player_detector: Area2D = $PlayerDetector
@onready var tile_map = $NavigationRegion2D/TileMap
@export var tile_index: int

var enemy: PackedScene = preload("res://Scenes/BaseEnemy.tscn")
var numberOfEnemies

func _ready(): 
	numberOfEnemies = enemies.get_child_count()
	
func close_entrances():
	for entry in entrance.get_children():
		if(entry is Marker2D):
			var entryPos = entry as Marker2D
			tile_map.set_cell(0, tile_map.local_to_map(entryPos.position + Vector2.DOWN) , 0, Vector2(6,0) )


func spawnEnemies() -> void:
	for enemyMarker in enemies.get_children():
		if enemyMarker is Marker2D:
			var enemyPos = enemyMarker as Marker2D
			
			var instantiatedEnemy = enemy.instantiate()
			
			instantiatedEnemy.position = enemyPos.position
			
			add_child(instantiatedEnemy)


func _on_player_detector_body_entered(body):
	close_entrances()
	spawnEnemies() 
	player_detector.queue_free()
