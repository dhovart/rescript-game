type t = {
  points: array<float>,
  bbox: BBox.t,
}

let getBBox = points => {
  let xs = points->Utils.filterByIndex(i => mod(i, 2) != 0)
  let ys = points->Utils.filterByIndex(i => mod(i, 2) == 0)
  let left = Utils.findMin(xs)
  let right = Utils.findMax(xs)
  let top = Utils.findMin(ys)
  let bottom = Utils.findMax(ys)
  BBox.make(~topLeft=Vec2.make(left, top), ~width=right -. left, ~height=bottom -. top, ())
}

let make = points => { points, bbox: getBBox(points) }