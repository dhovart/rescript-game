open Belt.Int
open Belt.Array

type t = {
  tree: QuadTree.t,
  camera: Camera.t,
  objects: array<GameObject.t>,
  player: ref<option<GameObject.t>>,
}

let make = () => {
    tree: QuadTree.make(~bbox=BBox.make(), ()),
    objects: [],
    camera: Camera.make(),
    player: ref(None),
}

let setObjects = (state, objects) => {...state, objects}
let setCamera = (state, camera) => {...state, camera}
let setTree = (state, tree) => {...state, tree}
let setPlayer = (state, player) => {
  state.player := Some(player)
  state
}

let updateCamera = (state, time) => {
  // FIXME move me
  state->setCamera(state.camera
    ->Camera.setPivot(switch state.player.contents {
      | Some(player) => player.entity.position
      | None => Vec2.make(0., 0.)
    })
    ->Camera.setZoom(switch state.player.contents {
    | Some(player) => Js.Math.min_float(
        2.5,
        Js.Math.max_float(0.8, player.entity.velocity->Vec2.length /. player.entity.maxSpeed *. 4.)
      )
    | None => 1.
    })
    // ->Camera.setRotation(Js.Math.sin(time->toFloat /. 1000.))
  )
}

let createTree = (state, screenRect) => {
  let topLeft = screenRect->Vec2.multiply(-.0.5)
  state->setTree(
    QuadTree.make(~bbox=BBox.make(~topLeft=topLeft, ~width=screenRect.x, ~height=screenRect.y, ()), ())
  )
}

let insertObjectsIntoTree = (state) =>
  state.objects->reduce(state.tree, (tree, object) => tree->QuadTree.insert(object.entity, state.camera))

let updateQuadTree = (state, screenRect) =>
  state->setTree(state->createTree(screenRect)->insertObjectsIntoTree)

let updateGameObjects = (state, input) => {
  open GameObject
  state->setObjects(state.objects->map(obj => {
    obj->update(input, state.player, state.tree, state.camera)->render
  }))
}

let update = (state, time, input, screenRect) => {
  state
  ->updateCamera(time)
  ->updateQuadTree(screenRect)
  ->updateGameObjects(input)
}
