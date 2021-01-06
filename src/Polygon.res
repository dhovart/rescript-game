type t = {
  points: array<float>,
  bbox: BBox.t,
  center: Vec2.t,
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

let make = points => {
  let bbox = getBBox(points)
  let center = bbox->BBox.getCenter
  {
    points,
    bbox,
    center
  }
}

let getPointsAsVectors = polygon => {
  Utils.pairs(polygon.points)->Belt.Array.keepMap(pair => switch pair {
  | [x, y] => Some(Vec2.make(x, y))
  | _ => None
  })
}

let getNormals = polygon => {
  let segments = Utils.pairs(polygon->getPointsAsVectors)
  segments->Belt.Array.keepMap(pair => switch pair {
    | [pointA, pointB] => Some(Segment.make(pointA, pointB)->Segment.getNormal(~clockwise=true, ()))
    | _ => None
  })
}

let collide = (polygon, other) => {
  let polygonNormals = polygon->getNormals
}