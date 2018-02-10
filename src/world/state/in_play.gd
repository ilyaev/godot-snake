extends "res://src/world/state/base.gd"

func _init():
    name = 'IN_PLAY'

func do_on_enter():
    scene.snake.set_target(scene.direction)


func ui_command(cmd):
    scene.snake.set_target(scene.direction)
    .ui_command(cmd)

func process(delta):
    scene.camera.align_to(scene.snake.head.get_pos())

func game_tick():
    if scene.need_spawn:
        scene.need_spawn = false
        scene.spawn_enemy_snake()
    scene.hud.update_score(String(1 + scene.snake.tail.get_children().size()), String(scene.snake.score))
    scene.hud.set_lifes(String(scene.session_lifes))
    scene.hud.update_player_position(scene.snake.head.get_pos(), scene.camera.get_offset(), scene.map.world_to_map(scene.snake.head.get_pos()), scene.map.maxX, scene.map.maxY)
