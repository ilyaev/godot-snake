extends Node2D

onready var global = get_node("/root/global")
onready var label_rank = get_node("label_node/label_rank")
onready var label_node = get_node("label_node")
onready var scorework_class = preload("res://src/particles/scorework.tscn")

var score_value = 0

signal oncontinue

func _ready():
	global.connect("rpc_response", self, "on_rpc_response")
	global.load_rank_by_score(score_value)
	var sw = scorework_class.instance()
	sw.set_pos(Vector2(rand_range(0,640) - 320,rand_range(0,480) - 240))
	add_child(sw)


func on_rpc_response(response, command):
	if command == global.RPC_SCORE_RANK:
		show_rank(response.data[global.RPC_SCORE_RANK])

func _on_tch_continue_pressed():
	emit_signal("oncontinue")

func show_rank(obj):
	label_rank.set_text("Rank so far " + obj.rankText)
	var pos = label_node.get_pos()
	var start_pos = pos + Vector2(0, 400)
	label_node.set_pos(start_pos)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(label_node, "transform/pos", start_pos, pos, 0.5, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

	label_rank.show()
