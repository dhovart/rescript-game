open Game
let game = make()

let poly = Polygon.make([
  96.19397662556435,69.13417161825448,
  69.1341716182545,96.19397662556435,
  30.865828381745512,96.19397662556435,
  3.806023374435661,69.1341716182545,
  3.806023374435661,30.865828381745516,
  30.865828381745484,3.806023374435675,
  69.1341716182545,3.806023374435668,
  96.19397662556432,30.86582838174548
])

let bunny = GameObject.make(
  1,
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  ~acceleration=0.5,
  ~maxSpeed=10.0,
  ~kind=Entity.Player,
  ~polygon=poly,
  ~rotation=0.7,
  (),
)

let worldSize = 1000.

let bunnies = Belt.Array.makeBy(1, i => GameObject.make(
    2 + i,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(-.worldSize/.2. +. Js.Math.random() *. worldSize, -.worldSize/.2. +. Js.Math.random() *. worldSize),
    ~acceleration=0.3,
    ~maxSpeed=8.0,
    ~kind=Entity.Enemy,
    ~velocityFactor=0.4,
    ~polygon=poly,
    ~rotation=-0.9,
    (),
  )
)

game
->appendObjects(bunnies)
->appendObject(bunny)
->setPlayer(bunny)
->init
