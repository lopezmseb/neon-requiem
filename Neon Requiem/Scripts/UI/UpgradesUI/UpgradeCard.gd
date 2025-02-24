extends Control
class_name UpgradeCard

@export var upgradeStrategy: UpgradeStrategy = null
@export var id : float = 0
@onready var description: RichTextLabel = $Button/VBoxContainer/Description
@onready var title: RichTextLabel = $Button/VBoxContainer/UpgradeTitle
@onready var levelText = $Button/VBoxContainer/LevelAmount

signal onClick(upgradeStrategy: UpgradeStrategy, id: float)

func _ready():
	if(upgradeStrategy):
		description.text = "[center]{description}".format({"description": upgradeStrategy.upgradeText})
		title.text = "[center]{title}".format({"title":upgradeStrategy.upgradeTitle})
		if(upgradeStrategy.level > 0):
			levelText.text = "[center]Level {level}".format({"level": upgradeStrategy.level})
		else:
			levelText.text = "[center]Not Acquired"
			
func _process(delta):
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if(upgradeStrategy):
		description.text = "[center]{description}".format({"description": upgradeStrategy.upgradeText})
		title.text = "[center]{title}".format({"title":upgradeStrategy.upgradeTitle})

func _input(event):
	if(Input.is_action_just_released("ui_accept") and has_focus()):
		#_on_pressed()
		pass

func _on_pressed():
	upgradeStrategy.OnPickup()
	onClick.emit(upgradeStrategy, id)
	$Overlay.visible = true
	$Button.disabled = true
