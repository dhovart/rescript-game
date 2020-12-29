let app = Game.make()

let bunnies = Belt.Array.makeBy(30, (i) => GameObject.make(
  j`lapin-$i`,
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~position=(Js.Math.random() *. 1600., Js.Math.random() *. 840.),
  ()))

let bunny = GameObject.make(
  "player",
  "https://pixijs.io/examples/examples/assets/bunny.png",
  ~controllable=true,
  ()
)


Belt.Array.forEach(bunnies, Game.appendObject(app))
Game.appendObject(app, bunny)

Game.init(app)
