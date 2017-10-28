extends Camera2D

var width = 640 * 2
var height = 480 * 2
var size
var scale
var original_offset

var original_zoom

func _ready():
	original_zoom = get_zoom()
	size_changed()
	get_tree().get_root().connect("size_changed", self, "size_changed")

func size_changed():
	size = get_tree().get_root().get_children()[0].get_viewport_rect().size
	scale = max(height / size.y, width / size.x)
	set_zoom(original_zoom * scale)
	original_offset = Vector2((size.x - width / scale) / 2, (size.y - height / scale) / 2) * -1 * original_zoom * scale
	set_offset(original_offset)


func align_to(pos):
	pass
	# set_offset(original_offset + pos * original_zoom * scale - (size / 2) * original_zoom * scale)
