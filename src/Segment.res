type point = Vec2.t

type t = {
  a: point,
  b: point,
}

let make = (a, b) => {a: a, b: b}

let getNormal = (segment, ~clockwise=true, ()) => {
  if clockwise {
    segment.b->Vec2.substract(segment.a)->Vec2.perpendicularClockwise
  } else {
    segment.b->Vec2.substract(segment.a)->Vec2.perpendicularCounterClockwise
  }
}
