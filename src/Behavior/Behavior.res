type t =
    | Seek(Entity.t, Entity.t, float)
    | Flee(Entity.t, Entity.t, float)
    | CowardlySeek(Entity.t, Entity.t, float)
    | SocialDistancing(Entity.t, QuadTree.t, Camera.t, float)
    | CollisionAvoidance(Entity.t, QuadTree.t, Camera.t, float)
    | Wander

let getSteering = (behavior, entity) => {
    switch(behavior) {
    | Seek(_, target, weight) => Seek.getSteering(entity, target, weight)
    | Flee(_, target, weight) => Flee.getSteering(entity, target, weight)
    | CowardlySeek(_, target, weight) => CowardlySeek.getSteering(entity, target, weight)
    | SocialDistancing(_, tree, camera, weight) => SocialDistancing.getSteering(entity, tree, camera, weight)
    | CollisionAvoidance(_, tree, camera, weight) => CollisionAvoidance.getSteering(entity, tree, camera, weight)
    | _ => Vec2.make(0., 0.)
    }
}