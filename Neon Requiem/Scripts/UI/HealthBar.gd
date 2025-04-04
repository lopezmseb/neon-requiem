extends Control
class_name HealthBar

@export var healthComponent: HealthComponent
@export var is_hidden: bool = true

@onready var timer = $HealthRemaining/TimeToCatchUp

var health = 0 : set = _setHealth


func setProgressBarValues(progressBar: ProgressBar, min, max, current):
	progressBar.min_value = min
	progressBar.max_value = max
	progressBar.value = current

func _ready():
	hide()
	setProgressBarValues($HealthRemaining, 0, healthComponent.MAX_HEALTH, healthComponent.currentHealth);

func _process(delta):
	updateHealthBar(delta)
	
func _setHealth(newHealth):
	var previousHealth = health
	health = min(healthComponent.MAX_HEALTH, newHealth)
	$HealthRemaining.value = health
	
	if(health < previousHealth):
		timer.start()

func updateHealthBar(delta):
	if(health != healthComponent.currentHealth):
		health = healthComponent.currentHealth

func _on_time_to_catch_up_timeout():
	$HealthRemaining/DamageTaken.value = health
