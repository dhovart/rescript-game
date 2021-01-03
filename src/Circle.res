type t = {
    position: Vec2.t,
    radius: float,
}

let make = (position, radius) => {position, radius}

let toScreenSpace = (circle, camera: Camera.t) => {
  let position = circle.position->
    ->Vec2.transform(~translation=camera.pivot, ~scale=camera.zoom, ())

  {
    position,
    radius: circle.radius *. camera.zoom,
  }    
}