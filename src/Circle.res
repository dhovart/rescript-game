type t = {
    position: Vec2.t,
    radius: float,
}

let make = (position, radius) => {position, radius}

let toScreenSpace = (circle, camera: Camera.t) => {
  let position = circle.position
    ->Vec2.toScreenSpace(
      ~rotation=camera.rotation,
      ~pivot=camera.pivot,
      ~zoom=camera.zoom,
      ())
  {
    position,
    radius: circle.radius *. camera.zoom,
  }    
}

let containsPoint = (circle, point: Vec2.t) => {
    ((point.x -. circle.position.x) *. (point.x -. circle.position.x) +.
    (point.y -. circle.position.y) *. (point.y -. circle.position.y)) <= circle.radius *. circle.radius
}