open PIXI

let app = Application.create(~options=Application.createApplicationOptions(
  ~backgroundColor=int_of_string("0x1099bb"),
  ~resolution=Webapi.Dom.window -> Obj.magic -> Js.Dict.unsafeGet("devicePixelRatio"), ()),
  ())

app
->Application.setResizeTo(#Window(Webapi.Dom.window))

Webapi.Dom.document
-> Webapi.Dom.Document.asHtmlDocument
-> Belt.Option.flatMap(document => document -> Webapi.Dom.HtmlDocument.body)
-> Belt.Option.map(body => body |> Webapi.Dom.Element.appendChild(app -> Application.getView))
-> ignore


app
-> Application.getView
-> Webapi.Dom.HtmlElement.style
-> Webapi.Dom.CssStyleDeclaration.setCssText("position: absolute; width: 100%; height: 100%")
-> ignore

let container = Container.create()

app 
-> Application.getStage 
-> Container.addChild(container)
-> ignore

// Create a new texture
let texture = Texture.from(~source=#String("https://pixijs.io/examples/examples/assets/bunny.png"), ())

let bunny = Sprite.create(texture)
bunny -> Sprite.setAnchor(ObservablePoint.create(~x=0.5, ~y=0.5, ~cb=() => (), ()))
bunny -> Sprite.setX(texture -> Texture.getWidth /. 2.)
bunny -> Sprite.setY(texture -> Texture.getHeight /. 2.)
container -> Container.addChild(bunny) -> ignore

// Center bunny sprite in local container coordinates
container -> Container.setPivot(ObservablePoint.create(
    ~x=container -> Container.getWidth /. 2.,
    ~y=container -> Container.getHeight /. 2.,
    ~cb=() => (),
()))

type vec2 = (float, float)
type direction = UP | DOWN | LEFT | RIGHT
type agent = {
  mutable acceleration: vec2,
  mutable position: vec2
}
let multiply = ((x, y), z) =>  (x *. z, y *. z)
let length = ((x, y)) =>  Js.Math.sqrt(x *. x +. y *. y)
let normalize = (vec2) => {
  let (x, y) = vec2
  let length = length(vec2)
  (x /. length, y /. length)
}

let bunny = { position: (0., 0.), acceleration: (0., 0.) }
let accelIncrease = 0.05
let maxSpeed = 3.

let direction = Rx.merge([
  Rx.fromEvent(~target=Webapi.Dom.document, ~eventName="keydown")
  |> Rx.Operators.mapn(e =>
    switch(e -> Webapi.Dom.KeyboardEvent.key) {
    | "ArrowUp" => Some(UP)
    | "ArrowDown" => Some(DOWN)
    | "ArrowLeft" => Some(LEFT)
    | "ArrowRight" => Some(RIGHT)
    | _ => None
    }
  ),
  Rx.fromEvent(~target=Webapi.Dom.document, ~eventName="keyup")
  |> Rx.Operators.mapn(e => None)
])
|> Rx.Operators.distinctUntilChanged()

let ticker = Rx.interval(~period=0, ~scheduler=Rx.animationFrame, ())

let screen = app -> Application.getScreen
let update = ((_, direction)) => {
  let (px, py) = bunny.position
  let (ax, ay) = bunny.acceleration

  let newAcceleration = switch(direction) {
    | Some(UP) => (ax, ay -. accelIncrease)
    | Some(DOWN) => (ax, ay +. accelIncrease)
    | Some(LEFT) => (ax -. accelIncrease, ay)
    | Some(RIGHT) => (ax +. accelIncrease, ay)
    | _ => (ax,ay)
  }

  bunny.acceleration = length(newAcceleration) > maxSpeed ?
    multiply(normalize(newAcceleration), maxSpeed) :
    newAcceleration

  container -> Container.setX(screen -> Rectangle.getWidth /. 2. +. px)
  container -> Container.setY(screen -> Rectangle.getHeight /. 2. +. py)
  container -> Container.setRotation(Js.Math._PI /. 2. +. Js.Math.atan2(~y=ay, ~x=ax, ()))

  bunny.position = (px +. ax, py +. ay)
}

let game = Rx.combineLatest2(ticker, direction)
|> Rx.Observable.subscribe(~next=update)