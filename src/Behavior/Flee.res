open Vec2

let getSteering = (entity: Entity.t, target: Entity.t, weight) => {
    let desired = Seek.getSteering(entity, target, 1.)
    desired->substract(entity.velocity)->limit(entity.maxSteeringForce)->multiply(-.1. *. weight)
}