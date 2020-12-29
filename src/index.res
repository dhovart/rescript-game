let bunny = GameObject.make(
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  ()
)
let monster = GameObject.make(
  "https://pixijs.io/examples/examples/assets/eggHead.png",
  ~position=(300., 100.),
  ())

let app = Game.make()
Game.init(app)
Game.appendGameObject(app, monster)
Game.appendGameObject(app, bunny)