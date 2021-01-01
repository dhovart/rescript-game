type t = {x: float, y: float}

let make = (x, y) => {x: x, y: y}
let add = ({x, y}, {x: u, y: v}) => {x: x +. u, y: y +. v}
let substract = ({x, y}, {x: u, y: v}) => {x: x -. u, y: y -. v}
let multiply = ({x, y}, z) => {x: x *. z, y: y *. z}
let divide = ({x, y}, z) => {x: x /. z, y: y /. z}
let length = ({x, y}) => Js.Math.sqrt(x *. x +. y *. y)
let normalize = vec2 => divide(vec2, length(vec2))
let asMatrix = vec2 => [[vec2.x, vec2.y, 1.]]
let transform = (vec2, mat) => {
  switch vec2->asMatrix->Matrix.multiply(mat) {
  | [[x, y, _]] => {
      {x, y}
    }
  | _ => vec2
  }
}
let asPixiPoint = ({x, y}) => PIXI.ObservablePoint.create(~x, ~y, ~cb=() => (), ())