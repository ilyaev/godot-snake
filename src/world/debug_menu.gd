extends Container

onready var popup = get_node("popup")

var menu_items = []

signal on_action

func _ready():
	for item in menu_items:
		popup.add_item(item["label"], item["action"])

	popup.connect("item_pressed", self, "on_menu_click")
	popup.set_pos(Vector2(300,300))
	popup.popup()
	pass

func on_menu_click(action):
	emit_signal("on_action", action)
