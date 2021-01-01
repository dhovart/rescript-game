open Game
let game = make()

let bunnies = Belt.Array.makeBy(30, i =>
  GameObject.make(
    j`lapin-$i`,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(Js.Math.random() *. 800., Js.Math.random() *. 600.),
    (),
  )
)

let bunny = GameObject.make(
  "player",
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  (),
)

Belt.Array.forEach(bunnies, game->appendObject)
game->appendObject(bunny)
game->setPlayer(bunny)
game->init
