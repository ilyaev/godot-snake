extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal finished


var score_value = 0
var tween
var tween2
onready var caption = get_node("caption")
onready var score = get_node("score")


func _ready():
	get_node("animator").play("show")
	get_node("score/score_label").set_text(str(score_value))
	pass


func _on_animator_finished():
	emit_signal("finished")
	pass # replace with function body


func _on_Timer_timeout():
	tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(caption, "transform/pos", caption.get_pos(), caption.get_pos() - Vector2(0, 300), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	tween2 = Tween.new()
	add_child(tween2)
	tween2.interpolate_property(score, "transform/pos", score.get_pos(), score.get_pos() - Vector2(0, 200), 0.6, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween2.start()
