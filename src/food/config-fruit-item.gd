extends Sprite

export var experience = 100
export var rarity = 1
export(String, "Fruit", "Spice", "Key", "Static") var type = 'Fruit'
export(int, "Normal", "Invinvcible", "Flash", "Slow") var state = 0
export(String, "Nothing", "FoodRain", "SnakeBin") var action = "Nothing"
export(String, "", "Pumpkin", "Skull") var anim = ""
export var state_duration = -1
export var available = true

func _ready():
	pass
