open Belt.Array

type t = {
  tree: QuadTree.t,
  camera: Camera.t,
  objects: array<GameObject.t>,
  player: ref<option<GameObject.t>>,
  zoomRef: ref<float>,
}

let make = () => {
    tree: QuadTree.make(~bbox=BBox.make(), ()),
    objects: [],
    camera: Camera.make(),
    player: ref(None),
    zoomRef: ref(0.)
}

let setObjects = (state, objects) => {...state, objects}
let setCamera = (state, camera) => {...state, camera}
let setTree = (state, tree) => {...state, tree}
let setPlayer = (state, player) => {
  state.player := Some(player)
  state
}

let updateCamera = (state, time, screenSize) => {
  // FIXME move me
  state->setCamera(state.camera
    ->Camera.setTranslation(screenSize->Vec2.divide(2.))
    ->Camera.setPivot(switch state.player.contents {
      | Some(player) => player.entity.position
      | None => Vec2.make(0., 0.)
    })
    ->Camera.setZoom(switch state.player.contents {
    | Some(player) => {
        let zoom = Js.Math.min_float(
        1.3,
        Js.Math.max_float(0.8, player.entity.velocity->Vec2.length /. player.entity.maxSpeed *. 2.)
      )
      let zoom = Utils.lerp(state.zoomRef.contents, zoom, 0.01) 
      state.zoomRef.contents = zoom
      zoom
    }
    | None => 1.
    })
  )
}

let createTree = (state, screenSize) => {
  let topLeft = screenSize->Vec2.multiply(-.0.5)
  state->setTree(
    QuadTree.make(~bbox=BBox.make(~topLeft=topLeft, ~width=screenSize.x, ~height=screenSize.y, ())->BBox.scale(1.5), ())
  )
}

let insertObjectsIntoTree = (state) =>
  state.objects->reduce(state.tree, (tree, object) => tree->QuadTree.insert(object.entity, state.camera))

let updateQuadTree = (state, screenSize) =>
  state->setTree(state->createTree(screenSize)->insertObjectsIntoTree)

let updateGameObjects = (state, input, debugGraphics) => {
  open GameObject
  state->setObjects(state.objects->map(obj => {
    obj->update(input, state.player, state.tree, state.camera, debugGraphics)->render
  }))
}

let update = (state, time, input, screenSize, debugGraphics) => {
  state
  ->updateCamera(time, screenSize)
  ->updateQuadTree(screenSize)
  ->updateGameObjects(input, debugGraphics)
}
