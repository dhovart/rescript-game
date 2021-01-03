open Belt.Array

let getSteering = (entity: Entity.t, tree, camera, weight) => {
  let neighbours = tree->QuadTree.circleQuery(Circle.make(entity.position, 200.), camera, ())
  neighbours
  ->reduce(Vec2.make(0., 0.), (acc, neighbour) => {
    if entity === neighbour || entity.kind === Entity.Player {
      acc
    } else {
      acc->Vec2.add({
        let dist = entity.position->Vec2.substract(neighbour.position)
        dist->Vec2.normalize->Vec2.divide(dist->Vec2.length)
      })
    }
  })
  ->Vec2.limit(entity.maxSteeringForce)
  ->Vec2.multiply(weight)
}
