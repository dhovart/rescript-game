type t = {
  points: Polyline.t,
  bbox: BBox.t,
  center: Vec2.t,
  normals: array<Vec2.t>,
}

let make = points => {
  let bbox = Polyline.getBBox(points)
  let center = bbox->BBox.getCenter
  let normals = points->Polyline.getNormals
  {
    points,
    bbox,
    center,
    normals
  }
}

let collide = (polygon, other) => {
  // let polygonNormals = polygon->Polyline.getNormals
  // let otherNormals = other->Polyline.getNormals
  false
}

let drawShape = (polygon, graphics: PIXI.Graphics.t) => {
  open PIXI.Graphics
  graphics
  ->lineStyle(~color=0, ())
  ->beginFill(~color=0x3500FA, ~alpha=0.4, ())
  ->drawPolygon(#Array(polygon.points))
  ->endFill
}

let drawNormals = (polygon, graphics: PIXI.Graphics.t) => {
  open PIXI.Graphics
  let segments = polygon.points->Polyline.getSegments
  let graphics = graphics->lineStyle(~color=0x00FF00, ~width=1., ())
  segments->Belt.Array.reduce(graphics, (graphics, segment) => {
    let normal = segment->Segment.getNormal(~clockwise=true, ())
    let position = segment.a->Vec2.add(segment.b)->Vec2.divide(2.)
    graphics->moveTo(~x=position.x, ~y=position.y)->lineTo(~x=position.x +. normal.x, ~y=position.y +. normal.y)
  })
}

let draw = (polygon, graphics) => {
  let graphics = polygon->drawShape(graphics)
  polygon->drawNormals(graphics)
}