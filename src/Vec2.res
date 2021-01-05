type t = {x: float, y: float}

let make = (x, y) => {x: x, y: y}
let map = (vec, fn) => {x: vec.x->fn, y: vec.y->fn}
let zipWith = (vec1, vec2, fn) => {x: vec1.x->fn(vec2.x), y: vec1.y->fn(vec2.y)}
let add = (vec1, vec2) => {x: vec1.x +. vec2.x, y: vec1.y +. vec2.y}
let substract = (vec1, vec2) => {x: vec1.x -. vec2.x, y: vec1.y -. vec2.y}
let multiply = (vec, scalar) => map(vec, x => x *. scalar)
let divide = (vec, scalar) => map(vec, x => x /. scalar)
let length = vec => Js.Math.sqrt(vec.x *. vec.x +. vec.y *. vec.y)
let normalize = vec => vec->divide(length(vec))
let dot = (vec1, vec2) => vec1.x *. vec2.x +. vec1.y *. vec2.y
let lerp = (vec1, vec2, percent) => vec1->zipWith(vec2, (start, end) => Utils.lerp(start, end, percent))
let transform = (vec: t, ~translation=make(0., 0.), ~scale=1., ~rotation=0., ()) => {
  open PIXI
  let mat = Matrix.create(~a=vec.x +. translation.x, ~b=vec.y +. translation.x, ())
  ->Matrix.scale(~x=scale, ~y=scale)
  ->Matrix.rotate(~angle=rotation)
  {x: mat->Matrix.getA, y: mat->Matrix.getB}
}
let limit = (vec, maxLength) => {
  if (vec->length > maxLength) {
    vec->normalize->multiply(maxLength)
  } else {
    vec
  }
}
let toScreenSpace = (vec, ~zoom=1., ~rotation=0., ()) => {
  vec->transform(~scale=zoom, ~rotation, ())
}
let angle = vec => Js.Math.atan2(~y=vec.y, ~x=vec.x, ())
let asPixiPoint = ({x, y}) => PIXI.ObservablePoint.create(~x, ~y, ~cb=() => (), ())