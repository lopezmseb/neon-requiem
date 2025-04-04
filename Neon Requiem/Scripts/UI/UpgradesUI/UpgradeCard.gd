extends Control
class_name UpgradeCard

@export var upgradeStrategy: UpgradeStrategy = null
@export var id : float = 0
@onready var description: RichTextLabel = $Button/VBoxContainer/Description
@onready var title: RichTextLabel = $Button/VBoxContainer/UpgradeTitle
@onready var levelText = $Button/VBoxContainer/LevelAmount
var isHovering = false

signal onClick(upgradeStrategy: UpgradeStrategy, id: float)

func upgradeStrategyFillInfo():
	if(upgradeStrategy):
		description.text = "[center]{description}".format({"description": upgradeStrategy.upgradeText})
		title.text = "[center]{title}".format({"title":upgradeStrategy.upgradeTitle})
		
		if(upgradeStrategy.upgradeImage):
			$Button/VBoxContainer/UpgradeImage.texture = upgradeStrategy.upgradeImage
		if(upgradeStrategy.level > 0):
			levelText.text = "[center]Level {level}".format({"level": upgradeStrategy.level})
		else:
			levelText.text = "[center]Not Acquired"

func _ready():
	upgradeStrategyFillInfo()
	
func _process(delta):
#	if the card is being hovered or in focus scale
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	pivot_offset = size/2
	upgradeStrategyFillInfo()

	var tween = get_tree().create_tween()
	if(has_focus() or isHovering):
		tween.tween_property($".", "scale",Vector2(1.025, 1.025), 0.2)
	else:
		tween.tween_property($".", "scale",Vector2(1, 1), 0.2)

func _on_pressed():
	upgradeStrategy.OnPickup()
	onClick.emit(upgradeStrategy, id)
	$Overlay.visible = true
	$".".disabled = true
	$Button.disabled = true

func _on_mouse_entered():
	isHovering = true

func _on_mouse_exit():
	isHovering = false
