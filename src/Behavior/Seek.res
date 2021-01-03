open Vec2

let getSteering = (entity: Entity.t, target: Entity.t, weight) => {
    let desired = target.position->substract(entity.position)
    ->normalize
    ->multiply(entity.maxSpeed)

    desired->substract(entity.velocity)->multiply(weight)->limit(entity.maxSteeringForce)
}