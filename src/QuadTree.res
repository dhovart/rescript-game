type rec t = {
  entity: option<Entity.t>,
  bbox: BBox.t,
  ne: option<t>,
  nw: option<t>,
  se: option<t>,
  sw: option<t>,
}

let make =(~bbox: BBox.t, ~entity=None, ()) => {
  entity,
  bbox,
  ne: None,
  nw: None,
  se: None,
  sw: None,
}

let getNode = (tree, quadrant: BBox.quadrant) =>
  switch (quadrant) {
  | SE => tree.se
  | NE => tree.ne
  | SW => tree.sw
  | NW => tree.nw
  }

let setNode = (tree: t, where: BBox.quadrant, node: t) =>
  switch (where) {
  | SE => {...tree, se: Some(node)}
  | NE => {...tree, ne: Some(node)}
  | SW => {...tree, sw: Some(node)}
  | NW => {...tree, nw: Some(node)}
  }

let createNode = (bbox: BBox.t, quadrant: BBox.quadrant, entity: Entity.t) => {
  let subquadrant = BBox.getSubquadrantBbox(bbox, quadrant)
  make(~bbox=subquadrant, ~entity=Some(entity), ())
}

let rec insert = (tree: t, entity: Entity.t) => {
  switch (tree.entity) {
  | Some(_) =>
    let quadrant = BBox.quadrantFromPoint(tree.bbox, entity.position)
    let child = getNode(tree, quadrant)

    switch (child) {
    | Some(node) => setNode(tree, quadrant, insert(node, entity))
    | None => setNode(tree, quadrant, createNode(tree.bbox, quadrant, entity))
    }
  | None => {...tree, entity: Some(entity)}
  }
}

let rec query = (tree, bbox: BBox.t, ~found=[], ()) => {
  if (!BBox.intersects(bbox, tree.bbox)) {
    found
  } else {
    let fromNE = switch(tree.ne) {
    | Some(ne) => query(ne, bbox, ~found=found, ())
    | None => []
    }
    let fromNW = switch(tree.nw) {
    | Some(nw) => query(nw, bbox, ~found=found, ())
    | None => []
    }
    let fromSE = switch(tree.se) {
    | Some(se) => query(se, bbox, ~found=found, ())
    | None => []
    }
    let fromSW = switch(tree.sw) {
    | Some(sw) => query(sw, bbox, ~found=found, ())
    | None => []
    }
    let fromCurrentNode = switch(tree.entity) {
    | Some(entity) => [entity]
    | None => []
    }
    Belt.Array.concatMany([found, fromCurrentNode, fromNE, fromNW, fromSE, fromSW])
  }
}

let rec draw = (tree, graphics): PIXI.Graphics.t => {
    let graphics = switch(tree.ne) {
    | Some(ne) => draw(ne, graphics)
    | None => graphics
    }
    let graphics = switch(tree.nw) {
    | Some(nw) => draw(nw, graphics)
    | None => graphics
    }
    let graphics = switch(tree.se) {
    | Some(se) => draw(se, graphics)
    | None => graphics
    }
    let graphics = switch(tree.sw) {
    | Some(sw) => draw(sw, graphics)
    | None => graphics
    }

    let { topLeft, width, height } = tree.bbox
    let (x, y) = topLeft
    graphics-> PIXI.Graphics.drawRect(~x=x, ~y=y, ~width=width, ~height=height)
}