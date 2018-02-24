extends Sprite

export var experience = 100
export var rarity = 1
export(String, "Fruit", "Spice", "Key", "Static") var type = 'Fruit'
export(int, "Normal", "Invinvcible", "Flash") var state = 0
export var state_duration = -1
export var available = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
