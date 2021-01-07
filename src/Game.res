open PIXI
open Belt.Array
open Belt.Int

type t = {
  app: Application.t,
  debug: bool,
  mutable state: GameState.t,
  debugGraphics: Graphics.t,
  loader: Loader.t,
  /* THe rendered scene */
  scene: Container.t,
  /* THe texture we render the scene to */
  renderTexture: RenderTexture.t,
  /* The sprite with the scene texture applied */
  mainSprite: Sprite.t,
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

  let size = getScreenDimensions()
  let brt = BaseRenderTexture.create(
    ~options=BaseRenderTexture.createOptions(~width=size.x, ~height=size.y, ()),
    (),
  )
  let renderTexture = RenderTexture.create(~baseRenderTexture=brt, ())
  {
    app,
    debug: true, // FIXME load from config or env var
    debugGraphics: Graphics.create(),
    scene: Container.create(),
    state: GameState.make(),
    loader: Loader.create(~baseUrl="/", ()),
    renderTexture,
    mainSprite: Sprite.create(renderTexture->Obj.magic),
  }
}

let getRenderer = game => game.app->Application.getRenderer

let updateScene = (game) => {
  game.scene->Container.setTransform(
    ~x=game.state.camera.translation.x,
    ~y=game.state.camera.translation.y,
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
    game.state.tree->QuadTree.draw(
      game.debugGraphics
      ->Graphics.clear
      ->Graphics.lineStyle(~color=0xFF0000, ~width=1., ())
      ->Graphics.moveTo(~x=0., ~y=0.)
    )->ignore
  }
  game
}

let renderScene = (game) => {
  game->getRenderer->PIXI.Renderer.render(
    ~displayObject=game.scene->Obj.magic,
    ~renderTexture=game.renderTexture->Obj.magic,
    (),
  )

  // let filters = Js.Nullable.return(switch game.state.player.contents {
  //   | None => []
  //   | Some(player) => {
  //     let zoomCenter = getScreenCenter()->Vec2.add(player.entity.velocity->Vec2.multiply(20.))
  //     let blurStrength = player.entity.velocity->Vec2.length *. 0.005

  //     [ZoomBlurFilter.create(~options=ZoomBlurFilter.createOptions(
  //       ~center=Point.create(~x=zoomCenter.x, ~y=zoomCenter.y, ()),
  //       ~strength=blurStrength,
  //       ()
  //     ))]
  //   }
  // })
  //  game.mainSprite->DisplayObject.setFilters(filters)->ignore

  game
}

let updateState = (game, time, input) => {
  game->setState(
    game.state->GameState.update(
      time,
      input,
      getScreenDimensions(),
      game.debugGraphics
    )
  )
}

let update = (game: t, (t, input)) => {
  game
  ->updateState(t, input)
  ->updateScene
  ->renderScene
//  ->renderDebugGraphics
  ->ignore
}

let start = game => {
  let ticker = Rx.interval(~period=1000, ~scheduler=Rx.animationFrame, ())
  Rx.combineLatest2(
    ticker |> Rx.Operators.startWith([0]),
    Input.playerDirection |> Rx.Operators.startWith([{
      let initialDirection: Input.direction = {x: None, y: None}
      initialDirection
    }]),
  )
  |> Rx.Observable.subscribe(~next=game->update)
  |> ignore
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

  game.app->Application.getStage->Container.addChild(game.mainSprite)->ignore

  let size = getScreenDimensions()

  game.mainSprite->Sprite.setWidth(size.x)
  game.mainSprite->Sprite.setHeight(size.y)

  if game.debug {
    game.app->Application.getStage->Container.addChild(game.debugGraphics)->ignore
    game.debugGraphics->Graphics.setTransform(
      ~x=size.x /. 2.,
      ~y=size.y /. 2.,
      ()
    )->ignore
  }
  game->start
}

// FIXME move me
let appendGameObjectDebugSprite = (game, gameObject) => {
  if game.debug {
    gameObject->GameObject.appendDebugSprite
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