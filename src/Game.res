open Belt.Array

type t = {
  app: PIXI.Application.t,
  debug: bool,
  mutable objects: array<GameObject.t>,
  mutable debugGraphics: PIXI.Graphics.t,
  mutable tree: QuadTree.t,
  mutable cameraTransforms: Matrix.t,
}

let getScreenDimensions = app => {
  let screen = app->PIXI.Application.getScreen
  Vec2.make(screen->PIXI.Rectangle.getWidth, screen->PIXI.Rectangle.getHeight)
}

let make = () => {
  let app = PIXI.Application.create(
    ~options=PIXI.Application.createApplicationOptions(
      ~backgroundColor=int_of_string("0x1099bb"),
      ~resolution=Webapi.Dom.window->Obj.magic->Js.Dict.unsafeGet("devicePixelRatio"),
      (),
    ),
    (),
  )
  let screenRect = getScreenDimensions(app)
  let tree = QuadTree.make(~bbox=BBox.make(Vec2.make(0., 0.), screenRect.x, screenRect.y), ())
  {
    app: app,
    objects: [],
    debug: true, // FIXME load from config or env var
    debugGraphics: PIXI.Graphics.create(),
    tree: tree,
    cameraTransforms: Matrix.makeIdentity(),
  }
}

let getScreenCenter = game => Vec2.divide(getScreenDimensions(game.app), 2.)
let getRenderer = game => game.app->PIXI.Application.getRenderer

let update = (game: t, (t, input)) => {
  let {x: width, y: height} = getScreenDimensions(game.app)
  game.tree = QuadTree.make(~bbox=BBox.make(Vec2.make(0., 0.), width, height), ())
  //game.cameraTransforms = Matrix.makeRotate(Js.Math.sin(Js.Int.toFloat(t) /. 100.))
  game.objects->forEach(obj => {
    open GameObject
    obj->update(input)->render(game.cameraTransforms)->ignore
    game.tree = game.tree->QuadTree.insert(obj.entity)
  })

  if game.debug {
    game.debugGraphics =
      game.tree->QuadTree.draw(
        game.debugGraphics
        ->PIXI.Graphics.clear
        ->PIXI.Graphics.lineStyle(~color=0xFF0000, ~width=1., ())
        ->PIXI.Graphics.moveTo(~x=0., ~y=0.),
      )
  }
}

let init = game => {
  game.app->PIXI.Application.setResizeTo(#Window(Webapi.Dom.window))

  game.app
  ->PIXI.Application.getView
  ->Webapi.Dom.HtmlElement.style
  ->Webapi.Dom.CssStyleDeclaration.setCssText("position: absolute; width: 100%; height: 100%")

  Webapi.Dom.document
  ->Webapi.Dom.Document.asHtmlDocument
  ->Belt.Option.flatMap(document => document->Webapi.Dom.HtmlDocument.body)
  ->Belt.Option.map(body =>
    body |> Webapi.Dom.Element.appendChild(game.app->PIXI.Application.getView)
  )
  ->ignore

  if game.debug {
    game.app->PIXI.Application.getStage->PIXI.Container.addChild(game.debugGraphics)->ignore
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

  game.app->PIXI.Application.getStage->PIXI.Container.addChild(gameObject.spriteContainer)->ignore
}
