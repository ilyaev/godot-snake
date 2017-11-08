extends Camera2D

var width = 640 * 2
var height = 480 * 2
var field_width = 640 * 2
var field_height = 480 * 2
var size
var scale
var original_offset
var perX
var perY
var min_margin = 3

var original_zoom

onready var map = get_node("/root/world/walls")

func _ready():
	original_zoom = get_zoom()
	width = map.maxX * map.snake_size
	height = map.maxY * map.snake_size
	size_changed()
	get_tree().get_root().connect("size_changed", self, "size_changed")

func size_changed():
	size = get_tree().get_root().get_children()[0].get_viewport_rect().size
	# scale = max(field_height / size.y, field_width / size.x)
	scale = field_height / size.y
	set_zoom(original_zoom * scale)
	perX = size.x / (map.snake_size / scale)
	perY = size.y / (map.snake_size / scale)


func align_to(pos):
	var offset = pos - (size / 2) * scale * original_zoom
	var cell = map.world_to_map(pos)
	offset.y = min((map.maxY - perY) * map.snake_size, max(offset.y, max(0, (pos.y / map.snake_size) * -1)))
	offset.x = min((map.maxX - perX) * map.snake_size, max(offset.x, max(0, (pos.x / map.snake_size) * -1)))
	if offset.x < 0:
		offset.x = offset.x / 2
	set_offset(offset)
