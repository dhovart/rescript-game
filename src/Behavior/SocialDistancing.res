open Belt.Array
open Belt.Int

let getSteering = (entity: Entity.t, tree, camera) => {
  // FIXME use circle query
  let neighbours = tree->QuadTree.bboxQuery(BBox.make(
      ~topLeft=entity.position->Vec2.substract(Vec2.make(40., 40.)),
      ~width=80.,
      ~height=80.,
      ())->BBox.toScreenSpace(camera),
      camera,
    ())

  // FIXME take proximity into account
  let div = neighbours->length > 0 ? neighbours->length->toFloat : 1.;
  neighbours->reduce(Vec2.make(0., 0.), (acc, neighbour) => {
    entity === neighbour ? acc : acc->Vec2.add(Flee.getSteering(entity, neighbour))
  })->Vec2.divide(div)
}
