type t =
    Seek(Entity.t, Entity.t)
    | Flee(Entity.t, Entity.t)
    | SocialDistancing(Entity.t, QuadTree.t, Camera.t)
    | Wander

let getSteering = (behavior, entity) => {
    switch(behavior) {
    | Seek(_, target) => Seek.getSteering(entity, target)
    | Flee(_, target) => Flee.getSteering(entity, target)
    | SocialDistancing(_, tree, camera) => SocialDistancing.getSteering(entity, tree, camera)
    | _ => Vec2.make(0., 0.)
    }
}