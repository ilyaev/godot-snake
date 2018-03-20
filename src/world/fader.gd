extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ttl = 2
var invert = false
var target_black = 1

signal faded

func _ready():
	var tween = Tween.new()
	add_child(tween)
	if invert:
		tween.interpolate_property(get_node("sprite"), "visibility/opacity", target_black, 0, ttl, Tween.TRANS_SINE, Tween.EASE_IN)
	else:
		tween.interpolate_property(get_node("sprite"), "visibility/opacity", 0, target_black, ttl, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.connect('tween_complete', self, 'do_faded', [tween])
	tween.start()
	pass

func do_faded(obj, key, timer):
	timer.queue_free()
	emit_signal("faded")

func reverse(ttl = 2):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(get_node("sprite"), "visibility/opacity", target_black, 0, ttl, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.connect('tween_complete', self, 'do_finish', [tween])
	tween.start()

func do_finish(obj, key, timer):
	timer.queue_free()
	queue_free()
