extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ttl = 2

func _ready():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(get_node("sprite"), "visibility/opacity", 0, 1, ttl, Tween.TRANS_SINE, Tween.EASE_IN)
	# tween.connect('tween_complete', self, 'do_proceed', [tween])
	tween.start()
	pass

func reverse(ttl = 2):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(get_node("sprite"), "visibility/opacity", 1, 0, ttl, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.connect('tween_complete', self, 'do_finish', [tween])
	tween.start()

func do_proceed(obj, key, timer):
	remove_child(timer)
	queue_free()
