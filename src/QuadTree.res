open BBox

type rec t = {
  entity: option<Entity.t>,
  bbox: BBox.t,
  ne: option<t>,
  nw: option<t>,
  se: option<t>,
  sw: option<t>,
}

let make = (~bbox: BBox.t, ~entity=None, ()) => {
  entity,
  bbox,
  ne: None,
  nw: None,
  se: None,
  sw: None,
}

let getNode = (tree, quadrant) =>
  switch quadrant {
  | SE => tree.se
  | NE => tree.ne
  | SW => tree.sw
  | NW => tree.nw
  }

let setNode = (tree, where, node) =>
  switch where {
  | SE => {...tree, se: Some(node)}
  | NE => {...tree, ne: Some(node)}
  | SW => {...tree, sw: Some(node)}
  | NW => {...tree, nw: Some(node)}
  }

let createNode = (bbox, quadrant, entity) => {
  let subquadrant = bbox->getSubquadrantBbox(quadrant)
  make(~bbox=subquadrant, ~entity=Some(entity), ())
}

let rec insert = (tree: t, entity: Entity.t, camera: Camera.t) => {
  let transformedEntityCenter = entity.position->Vec2.toScreenSpace(camera.pivot, camera.zoom, camera.rotation)
  switch(tree.bbox->BBox.containsPoint(transformedEntityCenter)) {
  | true => {
    switch tree.entity {
    | Some(_) =>
      let quadrant = tree.bbox->quadrantFromPoint(transformedEntityCenter)
      let child = getNode(tree, quadrant)

      switch child {
      | Some(node) => setNode(tree, quadrant, insert(node, entity, camera))
      | None => setNode(tree, quadrant, createNode(tree.bbox, quadrant, entity))
      }
    | None => {...tree, entity: Some(entity)}
    }
  }
  | false => tree
  }
}

let getQuadrants = tree => [tree.ne, tree.nw, tree.se, tree.sw]

let rec query = (tree, ~intersects, ~contains, ~found=[], ()) => {
  if !(intersects(tree)) {
    found
  } else {
    open Belt.Array
    let foundInQuadrants = tree->getQuadrants->reduce([], (acc, quadrant) =>
      acc->concat(
        switch quadrant {
        | Some(quadrant) => quadrant->query(~intersects, ~contains, ~found, ())
        | None => []
        }
      )
    )
    let foundInCurrentNode = switch tree.entity {
    | Some(entity) => contains(entity) ? [entity] : []
    | None => []
    }
    Belt.Array.concatMany([foundInCurrentNode, foundInQuadrants])
  }
}

let bboxQuery = (tree, bbox, camera) => tree->query(
  ~intersects=tree => bbox->intersects(tree.bbox),
  ~contains=entity => bbox->containsPoint(
    entity->Entity.getBBox(false)
    ->BBox.toScreenSpace(camera)
    ->BBox.getCenter
  )
)

let circleQuery = (tree, circle) => tree->query(
  ~intersects=tree => false, // FIXME
  ~contains=tree => false, // FIXME
)

let rec draw = (tree, graphics) => {
  open Belt.Array
  let graphics = tree->getQuadrants->reduce(graphics, (acc, quadrant) => switch quadrant {
  | Some(quadrant) => draw(quadrant, acc)
  | None => acc
  })

  let {topLeft, width, height} = tree.bbox
  let {x, y} = topLeft
  graphics->PIXI.Graphics.drawRect(~x, ~y, ~width, ~height)
}
