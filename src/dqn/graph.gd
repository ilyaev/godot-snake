var Mat = preload('mat.gd')

func Matrix(n,d):
    var tmp = Mat.new()
    tmp.init(n, d)
    return tmp

func init():
    pass

func mul(m1, m2):
    var n = m1.n
    var d = m2.d
    var out = Matrix(n, d)
    for i in range(0, m1.n):
        for j in range(0, m2.d):
            var dot = 0.0
            for k in range(0, m1.d):
                dot += m1.w[m1.d * i + k] * m2.w[m2.d * k + j]
            out.w[d*i+j] = dot
    return out

func add(m1, m2):
    var out = Matrix(m1.n, m1.d)
    for i in range(0, m1.w.size()):
        out.w[i] = m1.w[i] + m2.w[i]
    return out

func mtanh(m):
    var out = Matrix(m.n, m.d)
    for i in range(0, m.w.size()):
        out.w[i] = tanh(m.w[i])
    return out
