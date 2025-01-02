extends Control
class_name PlayerHealthBar

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthComponent = player.find_child("HealthComponent")


func setProgressBarValues(progressBar: ProgressBar, min, max, current):
	progressBar.min_value = min
	progressBar.max_value = max
	progressBar.value = current

func _ready():
	setProgressBarValues($PlayerHealthBar, 0, healthComponent.MAX_HEALTH, healthComponent.currentHealth);
	$PlayerHealthBar/RichTextLabel.text = "[center][b]{current}/{max}".format({"current": healthComponent.currentHealth, "max": healthComponent.MAX_HEALTH})

func _process(delta):
	$PlayerHealthBar.value = healthComponent.currentHealth
	$PlayerHealthBar/RichTextLabel.text = "[center][b]{current}/{max}".format({"current": healthComponent.currentHealth, "max": healthComponent.MAX_HEALTH})
	
