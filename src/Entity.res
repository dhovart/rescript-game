type t = {
  mutable velocity: Vec2.t,
  mutable steeringForce: Vec2.t,
  mutable position: Vec2.t,
  mutable rotation: float,
  maxSpeed: float,
  acceleration: float,
  name: string,
}

let make = (
  ~name: string,
  ~velocity=Vec2.make(0., 0.),
  ~steeringForce=Vec2.make(0., 0.),
  ~position=Vec2.make(0., 0.),
  ~maxSpeed=6.,
  ~acceleration=0.3,
  ~rotation=0.0,
  (),
) => {
  name,
  velocity,
  steeringForce,
  position,
  maxSpeed,
  acceleration,
  rotation,
}

let update = entity => {
  open Vec2
  // FIXME - add weights for behaviors
  entity.velocity = entity.velocity->add(entity.steeringForce->multiply(0.02))
  if (entity.velocity->length > entity.maxSpeed) {
    entity.velocity->normalize->multiply(entity.maxSpeed)->ignore
  }
  entity.velocity = entity.velocity->multiply(0.98)
  entity.rotation = Js.Math._PI /. 2. +. Js.Math.atan2(~y=entity.velocity.y, ~x=entity.velocity.x, ())
  entity.position = entity.position->add(entity.velocity)
  entity
}
