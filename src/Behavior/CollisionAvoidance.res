open Vec2
open Belt.Array

let aheadDistance = 10.;

let getSteering = (entity: Entity.t, tree, camera, weight) => {
  let ahead = entity.velocity->normalize->Vec2.multiply(aheadDistance)
  let neighbours = tree->QuadTree.circleQuery(Circle.make(entity.position, 200.), camera, ())
  neighbours->reduce(Vec2.make(0., 0.), (acc, neighbour) => {
    if entity->Entity.eq(neighbour) {
      acc
    } else {
        let neighbourBbox = neighbour->Entity.getBBox()
        let futurePosition = entity.position->Vec2.add(ahead)
        if neighbourBbox->BBox.containsPoint(futurePosition) {
            let avoidanceForce = futurePosition->Vec2.substract(neighbour.position)
            acc->add(avoidanceForce)
        } else {
            acc
        }
    }
  })
  ->Vec2.limit(entity.maxSteeringForce)
  ->Vec2.multiply(weight)
}