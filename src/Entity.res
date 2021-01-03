type kind = Enemy | Player | Obstacle | Bullet

type t = {
  velocity: Vec2.t,
  acceleration: Vec2.t,
  accelerationFactor: float,
  position: Vec2.t,
  rotation: float,
  maxSpeed: float,
  maxSteeringForce: float,
  name: string,
  polygon: Polygon.t,
  kind: kind,
  // rotationRef: ref<float>
}

let make = (
  ~name,
  ~kind,
  ~velocity=Vec2.make(0.,0.),
  ~position=Vec2.make(0., 0.),
  ~maxSpeed=6.,
  ~acceleration=Vec2.make(0.9, 0.0),
  ~accelerationFactor=0.3,
  ~maxSteeringForce=0.5,
  ~rotation=0.0,
  ~polygon=Polygon.make([]),
  (),
) => {
  name,
  kind,
  velocity,
  position,
  maxSpeed,
  acceleration,
  accelerationFactor,
  maxSteeringForce,
  rotation,
  polygon,
  // rotationRef: ref(rotation)
}

let setVelocity = (entity, velocity) => { ...entity, velocity }
let setAcceleration = (entity, acceleration) => { ...entity, acceleration }
let applyForce = (entity, force) => entity->setAcceleration(entity.acceleration->Vec2.add(force))

let update = entity => {
  // FIXME - add weights for behaviors
  let velocity = entity.velocity
    ->Vec2.add(entity.acceleration)
    ->Vec2.multiply(0.98)
    ->Vec2.limit(entity.maxSpeed)
  let desiredRotation = Js.Math._PI /. 2. +. Js.Math.atan2(~y=velocity.y, ~x=velocity.x, ())
  let rotation = desiredRotation
  // let rotation = Utils.lerp(entity.rotationRef.contents, desiredRotation, 0.06)
  // entity.rotationRef := rotation
  let position = entity.position->Vec2.add(velocity)
  {
    ...entity,
    velocity,
    rotation,
    position,
    acceleration: Vec2.make(0., 0.)
  }
}

let getBBox = (entity, ~rotate=false, ()) => {
  let bbox = if rotate {
    entity.polygon.bbox->BBox.getRotatedBBoxBBox(entity.rotation)
  } else {
    entity.polygon.bbox
  }
  bbox->BBox.setTopLeft(entity.position)
}