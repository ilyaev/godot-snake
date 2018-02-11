extends Container

onready var popup = get_node("popup")

var menu_items = []
var screen_size = Vector2(600,600)

signal on_action

func _ready():
	for item in menu_items:
		popup.add_item(item["label"], item["action"])

	popup.connect("item_pressed", self, "on_menu_click")
	var msize = popup.get_size() / 2 * popup.get_scale()
	popup.set_pos(screen_size / 2 - msize - Vector2(0, msize.y * 4))
	popup.popup()
	pass

func relocate(size):
	screen_size = size

func on_menu_click(action):
	emit_signal("on_action", action)
