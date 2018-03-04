extends Sprite

const STATE_PRESSED = 1
const STATE_RELEASED = 0

var state = STATE_RELEASED
var origin = Vector2(-1,-1)
var fix_point
var vobble = 1000
var shift_size = 20
var last_position = Vector2(0,0)

signal command

func _ready():
	set_process_input(true)
	fix_point = get_pos()
	vobble = vobble * get_scale().x
	shift_size = shift_size * get_scale().y
	pass


func _input(event):
	if state == STATE_PRESSED and event.type == InputEvent.SCREEN_DRAG:
		if origin.x == -1:
			origin = event.pos
			last_position = event.pos
		var direction = event.pos - origin
		set_pos(fix_point + Vector2(_cull(direction.x), _cull(direction.y)))

		var shift = event.pos - last_position
		if shift.length() >= shift_size:
			send_command(shift)
			last_position = event.pos


func send_command(shift):
	var cmd = ''
	if abs(shift.x) > abs(shift.y):
		if shift.x > 0:
			cmd = 'right'
		else:
			cmd = 'left'

	if !cmd:
		if shift.y > 0:
			cmd = 'down'
		else:
			cmd = 'up'

	if cmd:
		emit_signal("command", cmd)

func _cull(val):
	return max(-vobble, min(vobble, val))

func _on_TouchScreenButton_pressed():
	state = STATE_PRESSED


func _on_TouchScreenButton_released():
	state = STATE_RELEASED
	origin = Vector2(-1,-1)
	set_pos(fix_point)
