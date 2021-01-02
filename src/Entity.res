type t = {
  velocity: Vec2.t,
  steeringForce: Vec2.t,
  position: Vec2.t,
  rotation: float,
  maxSpeed: float,
  acceleration: float,
  name: string,
}

let make = (
  ~name: string,
  ~velocity=Vec2.make(0.,
  0.),
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

let setVelocity = (entity, velocity) => { ...entity, velocity }
let setSteeringForce = (entity, steeringForce) => { ...entity, steeringForce }

let update = entity => {
  // FIXME - add weights for behaviors
  let velocity = entity.velocity
    ->Vec2.add(entity.steeringForce->Vec2.multiply(0.02))
    ->Vec2.multiply(0.98)
    ->Vec2.limit(entity.maxSpeed)
  let rotation = Js.Math._PI /. 2. +. Js.Math.atan2(~y=velocity.y, ~x=velocity.x, ())
  let position = entity.position->Vec2.add(velocity)
  {
    ...entity,
    velocity,
    rotation,
    position,
  }
}