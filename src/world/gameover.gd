extends Node2D

signal finished


var score_value = 0
onready var caption = get_node("caption")
onready var score = get_node("score")
onready var rank = get_node("rank")
onready var global = get_node("/root/global")
onready var scorework_class = preload("res://src/particles/scorework.tscn")

func _ready():
	get_node("animator").play("show")
	get_node("score/score_label").set_text(str(score_value))
	rank.hide()
	rank.get_node("rank_label").set_text('')
	global.connect("rpc_response", self, "on_rpc_response")
	global.load_rank_by_score(score_value)

	for i in range(6):
		add_swork(Vector2(rand_range(0,640) - 320,rand_range(0,480) - 240), randf() * 2)


func on_rpc_response(response, command):
	if command == global.RPC_SCORE_RANK:
		show_rank(response.data[global.RPC_SCORE_RANK])


func show_rank(obj):
	rank.get_node("rank_label").set_text('Rank ' + str(obj.rankText))

func _on_animator_finished():
	emit_signal("finished")


func _on_Timer_timeout():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(caption, "transform/pos", caption.get_pos(), caption.get_pos() - Vector2(0, 300), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	var tween2 = Tween.new()
	add_child(tween2)
	tween2.interpolate_property(score, "transform/pos", score.get_pos(), score.get_pos() - Vector2(0, 220), 0.6, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween2.start()

	rank.show()
	get_node("rankanim").play("show")


func add_swork(pos, delay):
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "do_add_swork", [pos, timer])
	timer.set_wait_time(delay)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	add_child(timer)
	timer.start()

func do_add_swork(pos, timer):
	timer.queue_free()
	var sw = scorework_class.instance()
	sw.set_pos(pos)
	add_child(sw)