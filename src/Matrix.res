open Belt.Array
type t = array<array<float>>

let makeIdentity = () => [
    [1., 0., 0.],
    [0., 1., 0.],
    [0., 0., 1.]
]

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

let makeRotate = a => {
  let cos = Js.Math.cos(a);
  let sin = Js.Math.sin(a);
  [
    [cos, sin, 0.],
    [-.sin, cos, 0.],
    [0., 0., 1.]
  ]
}

let rec transpose = xs => {
  if xs->some(xs => xs->length === 0) {
    []
  } else {
    [xs->map(xs => xs[0])]->concat(
        transpose(xs->map(xs => xs->slice(~offset=1, ~len=xs->length)))
    )
  }
}

let multiply = (m1, m2) => {
  m1->mapWithIndex((i, xs) => xs->mapWithIndex((j, _) =>
    m1[i]->reduceWithIndex(0., ((acc, x, k) => acc +. x *. m2[j][k]))
  ))
}