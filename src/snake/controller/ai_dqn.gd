extends "base.gd"

var DQN
var features
var params
var map

const FEATURE_HEAD_COORDINATES = 1
const FEATURE_CLOSEST_FOOD_DICRECTION = 2
const FEATURE_TAIL_DIRECTION = 3
const FEATURE_VISION_CLOSE_RANGE = 4
const FEATURE_VISION_FAR_RANGE = 5
const FEATURE_VISION_MID_RANGE = 6
const FEATURE_TAIL_SIZE = 7
const FEATURE_HUNGER = 8

const actions = [{
    dx = 0,
    dy = 1
},
{
    dx = 0,
    dy = -1
},
{
    dx = 1,
    dy = 0
},
{
    dx = -1,
    dy = 0
}]

func _init():
    name = 'AI_DQN'

func initialize(params):
    DQN = params[0]
    params = DQN.dict.params
    features = DQN.dict.params.features


func build_state():
    var result = []
    var pos = snake.map.world_to_map(snake.head.get_pos())
    var food_pos = snake.map.world_to_map(snake.food.get_pos())
    var maxX = snake.map.maxX - 1
    var maxY = snake.map.maxY - 1
    for featureStr in features:
       var feature = int(featureStr)
       if feature == FEATURE_HEAD_COORDINATES:
            result.append(pos.x / maxX)
            result.append(pos.y / maxY)
       elif feature == FEATURE_CLOSEST_FOOD_DICRECTION:
            result.append((food_pos.x - pos.x) / maxX)
            result.append((food_pos.y - pos.y) / maxY)
       elif feature == FEATURE_VISION_CLOSE_RANGE:
            for action in actions:
                var flag = 0
                if snake.map.is_wall(Vector2(pos.x + action.dx, pos.y + action.dy)):
                    flag = 1
                result.append(flag)
    return result


func next_command():
    var state = build_state()
    var action = actions[DQN.act(state)]
    var command = Vector2(action.dx, action.dy)
    snake.set_target(command * snake.map.snake_size)

