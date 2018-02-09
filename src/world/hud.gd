extends CanvasLayer

onready var ui = get_node("ui")
onready var world = get_node("/root/world")
onready var label_score = get_node("ui/top_right/score")
onready var label_lifes = get_node("ui/top_right/lifes")
onready var label_experience = get_node("ui/top_left/score")
onready var score_animation = get_node("ui/top_right/animation")
onready var bottom_left = get_node("ui/bottom_left")
onready var bottom_right = get_node("ui/bottom_right")
onready var top_left = get_node("ui/top_left")
onready var top_right = get_node("ui/top_right")
onready var animation = get_node("ui/animation")

var hidable = []

var original_height = 0
var score = "0"
var experience = "0"

func _ready():
	original_height = ui.get_size().y
	label_score.set_text("2")
	label_lifes.set_text("3")
	hidable = [
		{
			'component': bottom_left,
			'animation': "bottom_left_visibility"
		},
		{
			'component': top_left,
			'animation': "top_left_visibility"
		},
		{
			'component': top_right,
			'animation': "top_right_visibility"
		},
		{
			'component': bottom_right,
			'animation': "bottom_right_visibility"
		}
	]
	pass

func rescale(zoom, offset):
	offset.x = min(0, offset.x)
	offset.y = min(0, offset.y)
	var size = get_tree().get_root().get_children()[1].get_viewport_rect().size
	size.x = (size.x + (offset.x * 2 / zoom.x)) * zoom.x
	size.y = size.y * zoom.y
	ui.set_size(size)
	ui.set_scale(Vector2(1,1) / zoom)
	ui.set_pos((offset / zoom) * -1)

func set_lifes(lifes):
	print("NEWF" , lifes)
	label_lifes.set_text(lifes)

func update_score(new_score, new_experience):
	if new_score == score and new_experience == experience:
		return
	score_animation.play("label")
	score = new_score
	experience = new_experience
	label_score.set_text(score)
	label_experience.set_text(experience)




func update_player_position(pos, offset,map_pos, maxX, maxY):
	var screen = pos - offset

	for one in hidable:
		var rect = Rect2(one.component.get_pos(), one.component.get_size())
		if rect.has_point(screen):
			if one.component.get_opacity() == 1:
				animation.play(one.animation)
		else:
			if one.component.get_opacity() < 1 and !animation.is_playing():
				animation.play_backwards(one.animation)




func _on_btn_left_pressed():
	world.ui_command('left')


func _on_btn_right_pressed():
	world.ui_command('right')


func _on_btn_up_pressed():
	world.ui_command('up')


func _on_btn_down_pressed():
	world.ui_command('down')
