type t = {
  mutable velocity: Vec2.t,
  mutable position: Vec2.t,
  maxSpeed: float,
  acceleration: float,
  name: string,
}

let make = (
  ~name: string,
  ~velocity=Vec2.make(0., 0.),
  ~position=Vec2.make(0., 0.),
  ~maxSpeed=6.,
  ~acceleration=0.3,
  (),
) => {
  name,
  velocity,
  position,
  maxSpeed,
  acceleration,
}

let update = entity => {
  open Vec2
  if (entity.velocity->length > entity.maxSpeed) {
    entity.velocity->normalize->multiply(entity.maxSpeed)->ignore
  }
  entity.velocity = entity.velocity->multiply(0.98)
  entity.position = entity.position->add(entity.velocity)
  entity
}
