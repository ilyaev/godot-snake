extends CanvasLayer

onready var ui = get_node("ui")
onready var world = get_node("/root/world")
onready var label_score = get_node("ui/top_right/score")
onready var label_experience = get_node("ui/top_left/score")
onready var animation = get_node("ui/top_right/animation")

var original_height = 0
var score = "0"
var experience = "0"

func _ready():
	original_height = ui.get_size().y
	label_score.set_text("2")
	pass

func rescale(zoom, offset):
	offset.x = min(0, offset.x)
	offset.y = min(0, offset.y)
	var size = get_tree().get_root().get_children()[0].get_viewport_rect().size
	size.x = (size.x + (offset.x * 2 / zoom.x)) * zoom.x
	size.y = size.y * zoom.y
	ui.set_size(size)
	ui.set_scale(Vector2(1,1) / zoom)
	ui.set_pos((offset / zoom) * -1)

func update_score(new_score, new_experience):
	if new_score == score and new_experience == experience:
		return
	animation.play("label")
	score = new_score
	experience = new_experience
	label_score.set_text(score)
	label_experience.set_text(experience)


