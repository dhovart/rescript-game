type t = Seek(Entity.t, Entity.t) | Flee(Entity.t, Entity.t) | Wander

let getSteering = (behavior, entity) => {
    switch(behavior) {
    | Seek(_, target) => Seek.getSteering(entity, target)
    | Flee(_, target) => Flee.getSteering(entity, target)
    | _ => Vec2.make(0., 0.)
    }
}