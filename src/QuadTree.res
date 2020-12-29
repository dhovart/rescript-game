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

let rec insert = (tree: t, entity: Entity.t) =>
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