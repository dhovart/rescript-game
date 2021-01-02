open Vec2

let getSteering = (entity: Entity.t, target: Entity.t) =>
    Seek.getSteering(entity, target)->multiply(-.1.)