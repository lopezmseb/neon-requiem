extends Control
class_name UpgradeCard

@export var upgradeStrategy: UpgradeStrategy = null
@onready var description: RichTextLabel = $ColorRect/Button/VBoxContainer/Description
@onready var title: RichTextLabel = $ColorRect/Button/VBoxContainer/UpgradeTitle

signal onClick

func _ready():

	if(upgradeStrategy):
		description.text = "[center]{description}".format({"description": upgradeStrategy.upgradeText})
		title.text = "[center]{title}".format({"title":upgradeStrategy.upgradeTitle})

func _process(delta):
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if(upgradeStrategy):
		description.text = "[center]{description}".format({"description": upgradeStrategy.upgradeText})
		title.text = "[center]{title}".format({"title":upgradeStrategy.upgradeTitle})


func _on_button_pressed():
	upgradeStrategy.OnPickup()
	queue_free()
	onClick.emit()
