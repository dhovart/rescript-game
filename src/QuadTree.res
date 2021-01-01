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
  let transformedEntityPosition = entity.position->Vec2.transform(
    Matrix.makeIdentity()
    ->Matrix.multiply(Matrix.makeTranslate(camera.pivot.x, camera.pivot.y))
    ->Matrix.multiply(Matrix.makeRotate(camera.rotation))
    ->Matrix.multiply(Matrix.makeScale(camera.zoom, camera.zoom))
  )
  switch(tree.bbox->BBox.contains(transformedEntityPosition)) {
  | true => {
    switch tree.entity {
    | Some(_) =>
      let quadrant = tree.bbox->quadrantFromPoint(transformedEntityPosition)
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

let rec query = (tree, bbox, ~found=[], ()) => {
  if !(bbox->intersects(tree.bbox)) {
    found
  } else {
    let fromNE = switch tree.ne {
    | Some(ne) => query(ne, bbox, ~found, ())
    | None => []
    }
    let fromNW = switch tree.nw {
    | Some(nw) => query(nw, bbox, ~found, ())
    | None => []
    }
    let fromSE = switch tree.se {
    | Some(se) => query(se, bbox, ~found, ())
    | None => []
    }
    let fromSW = switch tree.sw {
    | Some(sw) => query(sw, bbox, ~found, ())
    | None => []
    }
    let fromCurrentNode = switch tree.entity {
    | Some(entity) => [entity]
    | None => []
    }
    Belt.Array.concatMany([found, fromCurrentNode, fromNE, fromNW, fromSE, fromSW])
  }
}

let rec draw = (tree, graphics) => {
  let graphics = switch tree.ne {
  | Some(ne) => draw(ne, graphics)
  | None => graphics
  }
  let graphics = switch tree.nw {
  | Some(nw) => draw(nw, graphics)
  | None => graphics
  }
  let graphics = switch tree.se {
  | Some(se) => draw(se, graphics)
  | None => graphics
  }
  let graphics = switch tree.sw {
  | Some(sw) => draw(sw, graphics)
  | None => graphics
  }

  let {topLeft, width, height} = tree.bbox
  let {x, y} = topLeft
  graphics->PIXI.Graphics.drawRect(~x, ~y, ~width, ~height)
}
