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
  let obj = GameObject.make(
    j`lapin-$i`,
    "https://pixijs.io/examples/examples/assets/bunny.png",
    ~position=Vec2.make(Js.Math.random() *. 800., Js.Math.random() *. 600.),
    ~acceleration=Js.Math.random() *. 0.02,
    (),
  )
  obj
  // THIS IS BUGGY
  // let behavior = mod(i, 2) === 0 ?
  //   Behavior.Flee(obj.entity, bunny.entity) :
  //   Behavior.Seek(obj.entity, bunny.entity)
  // obj->GameObject.setBehavior(behavior)
})

game
->appendObjects(bunnies)
->appendObject(bunny)
->setPlayer(bunny)
->init
