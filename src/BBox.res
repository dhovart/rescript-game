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

let make = (topLeft, width, height) => {topLeft: topLeft, width: width, height: height}

let getSubquadrantBbox = (bbox: t, quadrant) => {
  let halfWidth = bbox.width /. 2.0
  let halfHeight = bbox.height /. 2.0

  let topLeftOffset = switch quadrant {
  | NW => (0.0, 0.0)
  | NE => (halfWidth, 0.0)
  | SW => (0.0, halfHeight)
  | SE => (halfWidth, halfHeight)
  }

  {width: halfWidth, height: halfHeight, topLeft: Vec2.add(bbox.topLeft, topLeftOffset)}
}

let quadrantFromPoint = (bbox, point: Vec2.t) => {
  let {topLeft, width, height} = bbox
  let center = Vec2.add(topLeft, (width /. 2.0, height /. 2.0))

  let (px, py) = point
  let (cx, cy) = center

  switch (px > cx, py > cy) {
  | (true, true) => SE
  | (true, false) => NE
  | (false, true) => SW
  | (false, false) => NW
  }
}

let contains = (bbox, entity: Entity.t) => {
  let (ex, ey) = entity.position
  let (x, y) = bbox.topLeft

  ex >= x && ey >= y && ex <= x +. bbox.width && ey <= +.y +. bbox.height
}

let intersects = (bbox, other) => {
  let (x, y) = bbox.topLeft
  let (ox, oy) = other.topLeft
  !(
    ox > x +. bbox.width || ox +. other.width < x || oy > y +. bbox.height || oy +. other.height < y
  )
}
