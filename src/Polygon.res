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
  let size = Vec2.make(right -. left, bottom -. top)
  let pos = Vec2.make(left, top)->Vec2.substract(size->Vec2.divide(2.))
  BBox.make(~topLeft=pos, ~width=size.x, ~height=size.y, ())
}

let make = points => { points, bbox: getBBox(points) }