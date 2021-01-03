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
let bunnies = Belt.Array.makeBy(300, i => GameObject.make(
    j`lapin-$i`,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(-.400. +. Js.Math.random() *. 800., -.300. +. Js.Math.random() *. 600.),
    ~acceleration=Js.Math.random(),
    ~kind=GameObject.Enemy,
    (),
  )
)

game
->appendObjects(bunnies)
->appendObject(bunny)
->setPlayer(bunny)
->init
