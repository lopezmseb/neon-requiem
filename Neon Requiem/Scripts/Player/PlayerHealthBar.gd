extends Control
class_name PlayerHealthBar

var player : Player
var healthComponent : HealthComponent

func setProgressBarValues(progressBar: ProgressBar, min, max, current):
	progressBar.min_value = min
	progressBar.max_value = max
	progressBar.value = current
	

func _ready():
	if(player):
		healthComponent = player.find_child("HealthComponent");
		setProgressBarValues($PlayerHealthBar, 0, healthComponent.MAX_HEALTH, healthComponent.currentHealth);
		$PlayerHealthBar/RichTextLabel.text = "[center][b]{current}/{max}".format({"current": healthComponent.currentHealth, "max": healthComponent.MAX_HEALTH})
	
func _process(delta):
	if(player):
		healthComponent = player.find_child("HealthComponent");
		setProgressBarValues($PlayerHealthBar, 0, healthComponent.MAX_HEALTH, healthComponent.currentHealth);
		$PlayerHealthBar.value = healthComponent.currentHealth
		$PlayerHealthBar/RichTextLabel.text = "[center][b]{current}/{max}".format({"current": healthComponent.currentHealth, "max": healthComponent.MAX_HEALTH})
	
