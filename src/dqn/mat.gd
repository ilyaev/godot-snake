var n
var d
var w
var dw

func zeros(num):
    var arr = []
    for one in range(0, num):
        arr.append(0)
    return arr

func setFrom(list):
    for i in range(0, list.size()):
        w[i] = list[i]

func fromJSON(json):
    n = json.n
    d = json.d
    w = zeros(n * d)
    dw = zeros(n * d)
    var wa = json.w.values()
    for i in range(0, n * d):
        w[i] = wa[i]

func maxIndex():
    var result = 0
    var maxr = -10000
    for i in range(0, w.size()):
        if w[i] > maxr:
            maxr = w[i]
            result = i
    return result

func init(mn, md):
    n = mn
    d = md
    w = zeros(n * d)
    dw = zeros(n * d)