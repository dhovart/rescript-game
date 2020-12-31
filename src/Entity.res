type t = {
  mutable velocity: Vec2.t,
  mutable position: Vec2.t,
  maxSpeed: float,
  acceleration: float,
  name: string,
}

let make = (
  ~name: string,
  ~velocity=(0.,0.),
  ~position=(0.,0.),
  ~maxSpeed=6.,
  ~acceleration=0.3,
()) => { name, velocity, position, maxSpeed, acceleration }

let update = (entity: t) => {
  entity.velocity =
    Vec2.length(entity.velocity) > entity.maxSpeed ?
    Vec2.multiply(Vec2.normalize(entity.velocity), entity.maxSpeed) :
    entity.velocity

  entity.velocity = Vec2.multiply(entity.velocity, 0.98) // friction

  let (vx, vy) = entity.velocity
  let (px, py) = entity.position
  entity.position = (px +. vx, py +. vy)
}