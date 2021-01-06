type t = {
  zoom: float,
  pivot: Vec2.t,
  rotation: float,
  translation: Vec2.t
}

let make = (
    ~zoom=1.,
    ~pivot=Vec2.make(0., 0.),
    ~rotation=0.,
    ~translation=Vec2.make(0., 0.),
    ()) => {
    zoom,
    pivot,
    rotation,
    translation
}

let setTranslation = (camera, translation) => {...camera, translation}
let setPivot = (camera, pivot) => {...camera, pivot}
let setZoom = (camera, zoom) => {...camera, zoom}
let setRotation = (camera, rotation) => {...camera, rotation}