type t = {x: float, y: float}

let make = (x, y) => {x: x, y: y}
let add = (vec1, vec2) => {x: vec1.x +. vec2.x, y: vec1.y +. vec2.y}
let substract = (vec1, vec2) => {x: vec1.x -. vec2.x, y: vec1.y -. vec2.y}
let multiply = (vec, x) => {x: vec.x *. x, y: vec.y *. x}
let divide = (vec, x) => {x: vec.x /. x, y: vec.y /. x}
let length = vec => Js.Math.sqrt(vec.x *. vec.x +. vec.y *. vec.y)
let normalize = vec => divide(vec, length(vec))
let dot = (vec1, vec2) => vec1.x *. vec2.x +. vec1.y *. vec2.y
let transform = (vec2: t, ~translation=make(0., 0.), ~scale=1., ~rotation=0., ()) => {
  open PIXI
  let mat = Matrix.create(~a=vec2.x +. translation.x, ~b=vec2.y +. translation.x, ())
  ->Matrix.scale(~x=scale, ~y=scale)
  ->Matrix.rotate(~angle=rotation)
  {x: mat->Matrix.getA, y: mat->Matrix.getB}
}
let limit = (vec2, maxLength) => {
  if (vec2->length > maxLength) {
    vec2->normalize->multiply(maxLength)
  } else {
    vec2
  } 
}
let toScreenSpace = (vec2, ~zoom=1., ~rotation=0., ()) => {
  vec2->transform(~scale=zoom, ~rotation, ())
}
let angle = vec => Js.Math.atan2(~y=vec.y, ~x=vec.x, ())
let asPixiPoint = ({x, y}) => PIXI.ObservablePoint.create(~x, ~y, ~cb=() => (), ())