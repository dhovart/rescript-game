open PIXI;

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

// Create a 5x5 grid of bunnies
Belt.Array.range(0, 24)
-> Belt.Array.forEach(i => {
  let bunny = Sprite.create(texture)
  bunny -> Sprite.setAnchor(ObservablePoint.create(~x=0.5, ~y=0.5, ~cb=() => (), ()))
  bunny -> Sprite.setX(float_of_int((mod(i, 5)) * 40))
  bunny -> Sprite.setY(floor(float_of_int(i) /. 5.) *. 40.)
  container -> Container.addChild(bunny) -> ignore
});

// Center bunny sprite in local container coordinates
container -> Container.setPivot(ObservablePoint.create(
    ~x=container -> Container.getWidth /. 2.,
    ~y=container -> Container.getHeight /. 2.,
    ~cb=() => (),
()))

let screen = app -> Application.getScreen

// Listen for animate update
app
-> Application.getTicker
-> Ticker.add(delta => {
  // rotate the container!
  // use delta to create frame-independent transform
  container -> Container.setRotation(container -> Container.getRotation -. 0.01);
  container -> Container.setX(screen -> Rectangle.getWidth /. 2.);
  container -> Container.setY(screen -> Rectangle.getHeight /. 2.);
}, ())
->ignore