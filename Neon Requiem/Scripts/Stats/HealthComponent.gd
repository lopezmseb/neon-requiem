extends Node
class_name HealthComponent

signal health_depleted(owner)
signal entity_damaged(attack:float)

@export var BASE_HEALTH: float = 100
@export var MAX_HEALTH : float = 100 : get = calcMaxHealth
@onready var currentHealth: float = BASE_HEALTH
@onready var healthPackScene = preload("res://Scenes/HealthPack.tscn")
@onready var speedBoostScene = preload("res://Scenes/SpeedBoost.tscn")


func damage(attack: AttackComponent):
	# If health == 0, don't run any more code
	if(currentHealth == 0):
		return
	
	var attackOwner := attack.get_owner().get_parent()	
	var target := get_owner()
	
	var upgradeDict = {"source": attackOwner, "target": target}
		
	var damage = attack.calculateDamage(upgradeDict)
	currentHealth -= damage
	entity_damaged.emit(damage)
	
	if(currentHealth <= 0):
		var parent = get_parent()
		if(parent is Player):
			health_depleted.emit(parent)
			parent.position = Vector2(999999,999999)
			parent.visible = false
			currentHealth = MAX_HEALTH
		else:
			health_depleted.emit(parent)
			var chance_25 = randf_range(0.0, 1.0) < 0.99
			
			if chance_25:
				var pickupObject
				#if randi() % 2:
				pickupObject = speedBoostScene.instantiate()
				#else:
					#pickupObject = healthPackScene.instantiate()
				pickupObject.position = parent.position
				parent.get_parent().call_deferred("add_sibling", pickupObject)



		

func calcMaxHealth():
	# Here we will run all health upgrades when implemented
	var maxHealth = BASE_HEALTH
	for i in get_children():
		var upgrade = i as UpgradeStrategy
		
		maxHealth = i.Apply(maxHealth)
		
	
	return maxHealth
