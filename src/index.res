open Game
let game = make()

let bunny = GameObject.make(
  "player",
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  ~acceleration=0.2,
  (),
)
let bunnies = Belt.Array.makeBy(30, i => {
  let object = GameObject.make(
    j`lapin-$i`,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(Js.Math.random() *. 800., Js.Math.random() *. 600.),
    ~acceleration=Js.Math.random() *. 0.02,
    (),
  )
  let behavior = mod(i, 2) === 0 ?
    Behavior.Flee(object.entity, bunny.entity) :
    Behavior.Seek(object.entity, bunny.entity)
  object->GameObject.setBehavior(behavior)
})

Belt.Array.forEach(bunnies, game->appendObject)
game->appendObject(bunny)
game->setPlayer(bunny)
game->init
