type t = {
  topLeft: Vec2.t,
  width: float,
  height: float,
}

type quadrant =
  | NE
  | NW
  | SE
  | SW

let make = (
  ~topLeft=Vec2.make(0.,0.),
  ~width=0.,
  ~height=0.,
  ()
) => {topLeft, width, height}

let setTopLeft = (bbox, topLeft) => {...bbox, topLeft}

let getSubquadrantBbox = (bbox: t, quadrant) => {
  let halfWidth = bbox.width /. 2.0
  let halfHeight = bbox.height /. 2.0

  let topLeftOffset = switch quadrant {
  | NW => Vec2.make(0.0, 0.0)
  | NE => Vec2.make(halfWidth, 0.0)
  | SW => Vec2.make(0.0, halfHeight)
  | SE => Vec2.make(halfWidth, halfHeight)
  }

  {width: halfWidth, height: halfHeight, topLeft: Vec2.add(bbox.topLeft, topLeftOffset)}
}

let quadrantFromPoint = (bbox, point: Vec2.t) => {
  let {topLeft, width, height} = bbox
  let center = Vec2.add(topLeft, Vec2.make(width /. 2.0, height /. 2.0))

  switch (point.x > center.x, point.y > center.y) {
  | (true, true) => SE
  | (true, false) => NE
  | (false, true) => SW
  | (false, false) => NW
  }
}

let containsPoint = (bbox, point: Vec2.t) => {
  point.x >= bbox.topLeft.x &&
  point.y >= bbox.topLeft.y &&
  point.x <= bbox.topLeft.x +. bbox.width &&
  point.y <= bbox.topLeft.y +. bbox.height
}

let contains = (bbox, other: t) => {
  other.topLeft.x >= bbox.topLeft.x &&
  other.topLeft.y >= bbox.topLeft.y &&
  other.topLeft.x +. other.width <= bbox.topLeft.x +. bbox.width &&
  other.topLeft.y +. other.height <= bbox.topLeft.y +. bbox.height
}

let intersects = (bbox, other) => {
  !(
    other.topLeft.x > bbox.topLeft.x +. bbox.width ||
    other.topLeft.x +. other.width < bbox.topLeft.x ||
    other.topLeft.y > bbox.topLeft.y +. bbox.height ||
    other.topLeft.y +. other.height < bbox.topLeft.y
  )
}

let getCenter = (bbox) => {
  bbox.topLeft->Vec2.add(Vec2.make(bbox.width/.2., bbox.height/.2.))
}

let getPoints = (bbox) => [
  bbox.topLeft,
  bbox.topLeft->Vec2.add(Vec2.make(bbox.width, 0.)),
  bbox.topLeft->Vec2.add(Vec2.make(bbox.width, bbox.height)),
  bbox.topLeft->Vec2.add(Vec2.make(0., bbox.height)),
]

let intersectsCircle = (bbox, circle: Circle.t) => {
  bbox->containsPoint(circle.position) ||
  bbox->getPoints->Belt.Array.reduce(false, (acc, point) => acc || circle->Circle.containsPoint(point))
}

let pointsToBBox = (points: array<Vec2.t>) => {
  open Belt.Array
  let leftmostPointX = points->reduce(points[0].x, (acc, curr) => Js.Math.min_float(acc, curr.x))
  let rightmostPointX = points->reduce(points[0].x, (acc, curr) => Js.Math.max_float(acc, curr.x))
  let topmostPointY = points->reduce(points[0].y, (acc, curr) => Js.Math.min_float(acc, curr.y))
  let bottommostPointY = points->reduce(points[0].y, (acc, curr) => Js.Math.max_float(acc, curr.y))

  {
    topLeft: Vec2.make(leftmostPointX, topmostPointY),
    width: rightmostPointX -. leftmostPointX,
    height: bottommostPointY -. topmostPointY,
  }
}

let getRotatedBBoxBBox = (bbox, rotation) => {
  bbox->getPoints
  ->Belt.Array.map(point => point->Vec2.transform(~rotation, ()))
  ->pointsToBBox
}

let scale = (bbox, scale) => 
  bbox->getPoints
  ->Belt.Array.map(point => point->Vec2.transform(~scale,()))
  ->pointsToBBox


let toScreenSpace = (bbox, camera: Camera.t) => {
  bbox->getPoints
  ->Belt.Array.map(point => point
    ->Vec2.substract(camera.pivot)
    ->Vec2.toScreenSpace(
    ~zoom=camera.zoom,
    ~rotation=camera.rotation,
    ()
  ))
  ->pointsToBBox
}
