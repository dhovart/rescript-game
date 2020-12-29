type t = {
  mutable acceleration: Vec2.t,
  mutable position: Vec2.t,
  maxSpeed: float,
  accelIncrease: float,
}

let make = (
  ~acceleration=(0.,0.),
  ~position=(0.,0.),
  ~maxSpeed=6.,
  ~accelIncrease=0.3,
()) => { acceleration, position, maxSpeed, accelIncrease }

let update = (entity: t) => {
  entity.acceleration =
    Vec2.length(entity.acceleration) > entity.maxSpeed ?
    Vec2.multiply(Vec2.normalize(entity.acceleration), entity.maxSpeed) :
    entity.acceleration

  entity.acceleration = Vec2.multiply(entity.acceleration, 0.98) // friction

  let (ax, ay) = entity.acceleration
  let (px, py) = entity.position
  entity.position = (px +. ax, py +. ay)
}