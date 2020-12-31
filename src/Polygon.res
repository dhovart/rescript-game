open Belt.Array

type t = {points: array<float>}

let make = points => {points: points}

let findMin = xs => xs->reduce(xs[0], Js.Math.min_float)
let findMax = xs => xs->reduce(xs[0], Js.Math.max_float)

let filterByIndex = (xs, filter) =>
  xs->reduceWithIndex([], (acc, x, i) => filter(i) ? acc : acc->concat([x]))

let getBBox = polygon => {
  let {points} = polygon
  let xs = points->filterByIndex(i => mod(i, 2) != 0)
  let ys = points->filterByIndex(i => mod(i, 2) == 0)

  let left = findMin(xs)
  let right = findMax(xs)

  let top = findMin(ys)
  let bottom = findMax(ys)

  BBox.make(Vec2.make(left, top), right -. left, bottom -. top)
}
