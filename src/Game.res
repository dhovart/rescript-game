open PIXI

type t = {
  app: Application.t,
  debug: bool,
  mutable objects: array<GameObject.t>,
  mutable debugGraphics: Graphics.t,
  mutable tree: QuadTree.t,
}

let getScreenDimensions = app => {
  let screen = app->Application.getScreen
  Vec2.make(screen->Rectangle.getWidth, screen->Rectangle.getHeight)
}

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
  let tree = QuadTree.make(~bbox=BBox.make(Vec2.make(0., 0.), screenRect.x, screenRect.y), ())
  {
    app,
    objects: [],
    debug: true, // FIXME load from config or env var
    debugGraphics: PIXI.Graphics.create(),
    tree,
  }
}

let getScreenCenter = game => Vec2.divide(getScreenDimensions(game.app), 2.)

let getRenderer = game => game.app->Application.getRenderer

let update = (game: t, (t, input)) => {
  let {x: width, y: height} = getScreenDimensions(game.app)
  game.tree = QuadTree.make(~bbox=BBox.make(Vec2.make(0., 0.), width, height), ())

  Belt.Array.forEach(game.objects, obj => {
    open GameObject
    obj->update(input)->render->ignore
    game.tree = game.tree->QuadTree.insert(obj.entity)
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
  ->Belt.Option.map(body => body |> Webapi.Dom.Element.appendChild(game.app->Application.getView))
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
  game.objects = Belt.Array.concat(game.objects, [gameObject])

  if game.debug {
    gameObject->GameObject.appendDebugSprite(getRenderer(game))
  }

  game.app->Application.getStage->Container.addChild(gameObject.spriteContainer)->ignore
}
