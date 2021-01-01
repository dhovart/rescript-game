type t = {
  mutable zoom: float,
  mutable pivot: Vec2.t,
  mutable rotation: float,
}

let make = (
    ~zoom=1.,
    ~pivot=Vec2.make(0., 0.),
    ~rotation=0.,
    ()) => {
    zoom,
    pivot,
    rotation
}
