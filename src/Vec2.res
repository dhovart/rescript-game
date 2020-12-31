type t = { x: float, y: float }

let make = (x, y) => {x, y}
let add = ({x, y}, {x: u, y: v}) => {x: x +. u, y: y +. v}
let substract = ({x, y}, {x: u, y: v}) => {x: x -. u, y: y -. v}
let multiply = ({x, y}, z) => {x: x *. z, y: y *. z}
let divide = ({x, y}, z) => {x: x /. z, y: y /. z}
let length = ({x, y}) => Js.Math.sqrt(x *. x +. y *. y)
let normalize = vec2 => divide(vec2, length(vec2))
