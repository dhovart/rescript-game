open Vec2

let getSteering = (entity: Entity.t, target: Entity.t, weight) => {
    let diff = target.position->substract(entity.position)
    let targetIsFacingEntity = diff->normalize->dot(target.velocity->normalize) <= 0.
    if(targetIsFacingEntity) {
        Flee.getSteering(entity, target, weight)
    } else {
        Seek.getSteering(entity, target, weight)
    }
}