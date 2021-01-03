open PIXI
open Belt.Array
open Belt.Int

type t = {
  app: Application.t,
  debug: bool,
  scene: Container.t,
  mutable state: GameState.t,
  mutable debugGraphics: Graphics.t,
}

let getScreenDimensions = () => {
  Vec2.make(
    Webapi.Dom.window->Webapi.Dom.Window.innerWidth->toFloat,
    Webapi.Dom.window->Webapi.Dom.Window.innerHeight->toFloat
  )
}

let setState = (game, state) => {
  game.state = state
  game
}

let getScreenCenter = () => Vec2.divide(getScreenDimensions(), 2.)

let make = () => {
  let app = Application.create(
    ~options=Application.createApplicationOptions(
      ~backgroundColor=int_of_string("0x1099bb"),
      ~resolution=Webapi.Dom.window->Obj.magic->Js.Dict.unsafeGet("devicePixelRatio"),
      (),
    ),
    (),
  )
  {
    app,
    debug: true, // FIXME load from config or env var
    debugGraphics: Graphics.create(),
    scene: Container.create(),
    state: GameState.make(),
  }
}

let getRenderer = game => game.app->Application.getRenderer
let setDebugGraphics = (game, debugGraphics) => {
  game.debugGraphics = debugGraphics
  game
}

let updateScene = (game) => {
  game.scene->Container.setTransform(
    ~pivotX=game.state.camera.pivot.x,
    ~pivotY=game.state.camera.pivot.y,
    ~scaleX=game.state.camera.zoom,
    ~scaleY=game.state.camera.zoom,
    ~rotation=game.state.camera.rotation,
  ())->ignore
  game
}

let renderDebugGraphics = (game) => {
  if game.debug {
    game->setDebugGraphics(
      game.state.tree->QuadTree.draw(
        game.debugGraphics
        ->Graphics.clear
        ->Graphics.lineStyle(~color=0xFF0000, ~width=1., ())
        ->Graphics.moveTo(~x=0., ~y=0.)
      )
    )
    ->ignore
  }
}

let updateState = (game, time, input) => {
  game->setState(
    game.state->GameState.update(
      time,
      input,
      getScreenDimensions(),
    )
  )
}

let update = (game: t, (t, input)) => {
  game
  ->updateState(t, input)
  ->updateScene
  ->renderDebugGraphics
  ->ignore
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

  let center = getScreenCenter()
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
  |> Rx.Observable.subscribe(~next=game->update)
  |> ignore
}

// FIXME move me
let appendGameObjectDebugSprite = (game, gameObject) => {
  if game.debug {
    gameObject->GameObject.appendDebugSprite(game->getRenderer)
  }
  game
}

let appendObject = (game, gameObject: GameObject.t) => {
  game.scene->Container.addChild(gameObject.spriteContainer)->ignore
  game->setState(
    game.state->GameState.setObjects(game.state.objects->concat([gameObject]))
  )
  ->appendGameObjectDebugSprite(gameObject)
}

let appendObjects = (game, gameObjects) => {
  gameObjects->reduce(game, (game, object) => game->appendObject(object))
}

let setPlayer = (game, player) => game->setState(game.state->GameState.setPlayer(player))