type t = {
  topLeft: Vec2.t,
  side: float,
}

type quadrant =
  | NE
  | NW
  | SE
  | SW

let getSubquadrantBbox = (bbox: t, quadrant) => {
  let halfSide = bbox.side /. 2.0

  let topLeftOffset =
    switch (quadrant) {
    | NW => (0.0, 0.0)
    | NE => (halfSide, 0.0)
    | SW => (0.0, halfSide)
    | SE => (halfSide, halfSide)
    }

  {side: halfSide, topLeft: Vec2.add(bbox.topLeft, topLeftOffset)}
}

let quadrantFromPoint = (bbox, point: Vec2.t) => {
  let { topLeft, side } = bbox
  let center = Vec2.add(topLeft, (side /. 2.0, side /. 2.0))

  let (px, py) = point
  let (cx, cy) = center

  switch (px > cx, py > cy) {
  | (true, true) => SE
  | (true, false) => NE
  | (false, true) => SW
  | (false, false) => NW
  }
}