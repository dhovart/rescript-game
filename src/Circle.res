type t = {
    position: Vec2.t,
    radius: float,
}

let make = (position, radius) => {position, radius}

let toScreenSpace = (circle, camera: Camera.t) => {
  let position = circle.position->Vec2.substract(camera.pivot)
    ->Vec2.transform(Matrix.makeScale(camera.zoom, camera.zoom)
      ->Matrix.multiply(Matrix.makeRotate(camera.rotation)))

  {
    position,
    radius: circle.radius *. camera.zoom,
  }    
}