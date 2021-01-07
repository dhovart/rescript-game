type t = {
  /* A polygon is a closed shape defined by a polyline */
  shape: Polyline.t,
  points: array<Vec2.t>,
  bbox: BBox.t,
  center: Vec2.t,
  normals: array<Vec2.t>,
}

let make = polyline => {
  let bbox = Polyline.getBBox(polyline)
  let center = bbox->BBox.getCenter
  let normals = polyline->Polyline.getNormals
  let points = polyline->Polyline.getPointsAsVec2->Belt.Array.map(Vec2.substract(_, Vec2.make(bbox.width /. 2., bbox.height /. 2.)))
  {
    shape: polyline,
    points,
    bbox,
    center,
    normals
  }
}

let getPointsAsVec2 = points => {
  open Belt.Array
  points->reduceWithIndex([], (vec2s, point, i) => {
    vec2s->concat(
      if mod(i, 2) == 0 {
        []
      } else {
        switch (points->get(i - 1), point) {
        | (Some(x), y) => [Vec2.make(x, y)]
        | _ => []
        }
      },
    )
  })
}

let drawShape = (polygon, graphics: PIXI.Graphics.t) => {
  open PIXI.Graphics
  graphics
  ->lineStyle(~color=0, ())
  ->beginFill(~color=0x3500FA, ())
  ->drawPolygon(#Array(polygon.shape))
  ->endFill
}

let drawNormals = (polygon, graphics: PIXI.Graphics.t) => {
  open PIXI.Graphics
  let segments = polygon.shape->Polyline.getSegments
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