open PIXI
open Belt.Array
open Belt.Int

type t = {
  app: Application.t,
  debug: bool,
  mutable objects: array<GameObject.t>,
  mutable debugGraphics: Graphics.t,
  mutable tree: QuadTree.t,
  mutable scene: Container.t,
  mutable player: option<GameObject.t>,
  camera: Camera.t,
}

let getScreenDimensions = app => {
  Vec2.make(
    Webapi.Dom.window->Webapi.Dom.Window.innerWidth->toFloat,
    Webapi.Dom.window->Webapi.Dom.Window.innerHeight->toFloat
  )
}

let getScreenCenter = game => Vec2.divide(getScreenDimensions(game.app), 2.)

let make = () => {
  let app = Application.create(
    ~options=Application.createApplicationOptions(
      ~backgroundColor=int_of_string("0x1099bb"),
      ~resolution=Webapi.Dom.window->Obj.magic->Js.Dict.unsafeGet("devicePixelRatio"),
      (),
    ),
    (),
  )
  let screenRect = getScreenDimensions(app)
  let topLeft = screenRect->Vec2.multiply(-.0.5)
  let tree = QuadTree.make(~bbox=BBox.make(topLeft, screenRect.x, screenRect.y), ())
  {
    app,
    objects: [],
    debug: true, // FIXME load from config or env var
    debugGraphics: Graphics.create(),
    tree,
    camera: Camera.make(),
    player: None,
    scene: Container.create()
  }
}

let setPlayer = (game, player) => game.player = Some(player)
let getRenderer = game => game.app->Application.getRenderer

let update = (game: t, (t, input)) => {
  let screenRect = game.app->getScreenDimensions
  let topLeft = screenRect->Vec2.multiply(-.0.5)
  game.tree = QuadTree.make(~bbox=BBox.make(topLeft, screenRect.x, screenRect.y), ())
  
  game.camera.pivot = switch game.player {
  | Some(player) => player.entity.position
  | None => Vec2.make(0., 0.)
  }

  game.camera.rotation = Js.Math.sin(t->toFloat /. 1000.)
  game.camera.zoom = Js.Math.abs_float(Js.Math.cos(t->toFloat /. 1000.))

  game.scene->Container.setTransform(
    ~pivotX=game.camera.pivot.x,
    ~pivotY=game.camera.pivot.y,
    ~scaleX=game.camera.zoom,
    ~scaleY=game.camera.zoom,
    ~rotation=game.camera.rotation,
  ())->ignore

  game.objects->forEach(obj => {
    open GameObject
    obj->update(input)->render->ignore
    game.tree = game.tree->QuadTree.insert(obj.entity, game.camera)
  })

  if game.debug {
    game.debugGraphics =
      game.tree->QuadTree.draw(
        game.debugGraphics
        ->Graphics.clear
        ->Graphics.lineStyle(~color=0xFF0000, ~width=1., ())
        ->Graphics.moveTo(~x=0., ~y=0.),
      )
  }
}

let init = game => {
  game.app->Application.setResizeTo(#Window(Webapi.Dom.window))

  game.app
  ->Application.getView
  ->Webapi.Dom.HtmlElement.style
  ->Webapi.Dom.CssStyleDeclaration.setCssText("position: absolute; width: 100%; height: 100%")

  Webapi.Dom.document
  ->Webapi.Dom.Document.asHtmlDocument
  ->Belt.Option.flatMap(document => document->Webapi.Dom.HtmlDocument.body)
  ->Belt.Option.map(body =>
    body |> Webapi.Dom.Element.appendChild(game.app->Application.getView)
  )
  ->ignore

  game.app->Application.getStage->Container.addChild(game.scene)->ignore

  let center = game->getScreenCenter
  game.app->Application.getStage->Container.setTransform(
      ~x=center.x,
      ~y=center.y,
      ())
  ->ignore

  if game.debug {
    game.app->Application.getStage->Container.addChild(game.debugGraphics)->ignore
  }

  let ticker = Rx.interval(~period=0, ~scheduler=Rx.animationFrame, ())

  Rx.combineLatest2(
    ticker |> Rx.Operators.startWith([0]),
    Input.playerDirection |> Rx.Operators.startWith([None]),
  )
  |> Rx.Observable.subscribe(~next=update(game))
  |> ignore
}

let appendObject = (game, gameObject) => {
  game.objects = game.objects->concat([gameObject])

  if game.debug {
    gameObject->GameObject.appendDebugSprite(getRenderer(game))
  }

  game.scene->Container.addChild(gameObject.spriteContainer)->ignore
}
