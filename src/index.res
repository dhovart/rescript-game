open Game
let game = make()

let bunny = GameObject.make(
  "player",
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  ~acceleration=0.5,
  ~maxSpeed=10.0,
  ~kind=GameObject.Player,
  (),
)

let worldSize = 1000.

let bunnies = Belt.Array.makeBy(100, i => GameObject.make(
    j`lapin-$i`,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(-.worldSize/.2. +. Js.Math.random() *. worldSize, -.worldSize/.2. +. Js.Math.random() *. worldSize),
    ~acceleration=0.1,
    ~kind=GameObject.Enemy,
    (),
  )
)

game
->appendObjects(bunnies)
->appendObject(bunny)
->setPlayer(bunny)
->init
