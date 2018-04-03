var nh
var ns
var na
var net
var dict = {}

var Mat = preload('mat.gd')
var Graph = preload('graph.gd')

var mutex = Mutex.new()

func Matrix(n,d):
    var tmp = Mat.new()
    tmp.init(n, d)
    return tmp

func init():
    pass

func act(slist):
    var s = Matrix(ns, 1)
    s.setFrom(slist)
    var amat = forwardQ(net, s)
    return amat.maxIndex()

func forwardQ(fnet, s):
    var G = Graph.new()
    G.init()
    var a1mat = G.add(G.mul(fnet.W1, s), fnet.b1)
    var h1mat = G.mtanh(a1mat)
    var a2mat = G.add(G.mul(fnet.W2, h1mat), fnet.b2)
    return a2mat

func netFromJSON(j):
    var net = {}
    for p in j.keys():
        net[p] = Matrix(1,1)
        net[p].fromJSON(j[p])
    return net

func fromJSON(fileName):
    var file = File.new()
    file.open(fileName, file.READ)
    var text = file.get_as_text()
    dict.parse_json(text)
    file.close()
    var j = dict.brain
    nh = j.nh
    ns = j.ns
    na = j.na
    net = netFromJSON(j.net)

func release():

    print("RELEASE DQN")
    net.clear()