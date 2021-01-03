type t = {x: float, y: float}

let make = (x, y) => {x: x, y: y}
let add = ({x, y}, {x: u, y: v}) => {x: x +. u, y: y +. v}
let substract = ({x, y}, {x: u, y: v}) => {x: x -. u, y: y -. v}
let multiply = ({x, y}, z) => {x: x *. z, y: y *. z}
let divide = ({x, y}, z) => {x: x /. z, y: y /. z}
let length = ({x, y}) => Js.Math.sqrt(x *. x +. y *. y)
let normalize = vec2 => divide(vec2, length(vec2))
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
let toScreenSpace = (vec2, ~zoom, ~rotation, ()) => {
  vec2->transform(~scale=zoom, ~rotation, ())
}
let asPixiPoint = ({x, y}) => PIXI.ObservablePoint.create(~x, ~y, ~cb=() => (), ())