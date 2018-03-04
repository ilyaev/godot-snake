extends Sprite

signal command

func _ready():
	pass


func _on_btn_left_pressed():
	emit_signal("command", "left")


func _on_btn_right_pressed():
	emit_signal("command", "right")


func _on_btn_up_pressed():
	emit_signal("command", "up")


func _on_btn_down_pressed():
	emit_signal("command", "down")
