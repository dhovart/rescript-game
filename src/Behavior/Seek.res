open Vec2

let getSteering = (entity: Entity.t, target: Entity.t) =>
    target.position
    ->substract(entity.position)
    ->normalize
    ->multiply(entity.maxSpeed)