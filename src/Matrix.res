open Belt.Array
type t = array<array<float>>

let makeTranslate = (x, y) => [
    [1., 0., x],
    [0., 1., y],
    [0., 0., 1.]
]

let makeScale = (w, h) => [
    [w, 0., 0.],
    [0., h, 0.],
    [0., 0., 1.]
]

let makeRotate = a => [
    [Js.Math.cos(a), Js.Math.sin(a), 0.],
    [-.Js.Math.sin(a), Js.Math.cos(a), 0.],
    [0., 0., 1.]
]

let rec transpose = xs => {
  if xs->some(xs => xs->length === 0) {
    []
  } else {
    [xs->map(xs => xs[0])]->concat(
        transpose(xs->map(xs => xs->slice(~offset=1, ~len=xs->length)))
    )
  }
}

let rowsSums = mat => mat->map(row => row->reduce(0.0, \"+."))

let multiply = (m1, m2) => {
  let rowsSumsFromM1 =  m1->rowsSums
  let colsSumsFromM2 = m2->transpose->rowsSums
  m1->mapWithIndex((i, xs) => xs->mapWithIndex((j, _) => rowsSumsFromM1[i] +. colsSumsFromM2[j]))
}
