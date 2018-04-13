extends Node2D

var height = 55
var start_pos = Vector2(0, 400)
var position = 0

onready var name = get_node("name")
onready var score = get_node("score")

func _ready():
	name.set_text("")
	name.set_text("")
	roll_in()
	pass

func update(label, value):
	name.set_text(label)
	score.set_text(str(value))

func roll_in():
	var tween = Tween.new()
	tween.connect('tween_complete', self, "tween_complete", [tween])
	add_child(tween)
	var new_pos = get_pos()
	set_pos(start_pos)
	var trans = Tween.TRANS_BACK
	# trans = randi() % 11
	tween.interpolate_property(self, "transform/pos", start_pos, new_pos, 0.5 + position * 0.1, trans, Tween.EASE_OUT)
	tween.start()

func tween_complete(obj, key, tween):
	tween.queue_free()
