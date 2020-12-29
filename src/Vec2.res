type t = (float, float)

let add = ((x, y), (u, v)) =>  (x +. u, y +. v)
let multiply = ((x, y), z) =>  (x *. z, y *. z)
let divide = ((x, y), z) =>  (x /. z, y /. z)
let length = ((x, y)) =>  Js.Math.sqrt(x *. x +. y *. y)
let normalize = (vec2) => {
  let (x, y) = vec2
  let length = length(vec2)
  (x /. length, y /. length)
}