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

let make = (topLeft, width, height) => {topLeft, width, height}

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

let contains = (bbox, entity: Entity.t) => {
  entity.position.x >= bbox.topLeft.x &&
  entity.position.y >= bbox.topLeft.y &&
  entity.position.x <= bbox.topLeft.x +. bbox.width &&
  entity.position.y <= +. bbox.topLeft.y +. bbox.height
}

let intersects = (bbox, other) => {
  !(
    other.topLeft.x > bbox.topLeft.x +. bbox.width ||
    other.topLeft.x +. other.width < bbox.topLeft.x ||
    other.topLeft.y > bbox.topLeft.y +. bbox.height ||
    other.topLeft.y +. other.height < bbox.topLeft.y
  )
}
