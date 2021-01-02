type t = {
  zoom: float,
  pivot: Vec2.t,
  rotation: float,
}

let make = (
    ~zoom=1.,
    ~pivot=Vec2.make(0., 0.),
    ~rotation=0.,
    ()) => {
    zoom,
    pivot,
    rotation
}

let setPivot = (camera, pivot) => {...camera, pivot}
let setZoom = (camera, zoom) => {...camera, zoom}
let setRotation = (camera, rotation) => {...camera, rotation}