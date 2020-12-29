open PIXI

type t = {
    app: Application.t,
    mutable objects: array<GameObject.t>
}

let make = () => {
    { app: Application.create(~options=Application.createApplicationOptions(
        ~backgroundColor=int_of_string("0x1099bb"),
        ~resolution=Webapi.Dom.window -> Obj.magic -> Js.Dict.unsafeGet("devicePixelRatio"), ()),
        ()),
        objects: []
    }
}

let getScreenCenter = (game: t) => {
    let screen = game.app -> Application.getScreen
    (screen -> Rectangle.getWidth /. 2., screen -> Rectangle.getHeight /. 2.)
}

let update = (game: t, (t, input)) => {
    let center = getScreenCenter(game)
    Js.log(t)
    Belt.Array.forEach(game.objects, obj => {
        GameObject.update(obj, input)
        GameObject.render(obj, center)
    })
}

let init = (game: t) => {
    game.app
    -> Application.setResizeTo(#Window(Webapi.Dom.window))

    game.app
    -> Application.getView
    -> Webapi.Dom.HtmlElement.style
    -> Webapi.Dom.CssStyleDeclaration.setCssText("position: absolute; width: 100%; height: 100%")
    -> ignore

    Webapi.Dom.document
    -> Webapi.Dom.Document.asHtmlDocument
    -> Belt.Option.flatMap(document => document -> Webapi.Dom.HtmlDocument.body)
    -> Belt.Option.map(body => body |> Webapi.Dom.Element.appendChild(game.app -> Application.getView))
    -> ignore

    let ticker = Rx.interval(~period=0, ~scheduler=Rx.animationFrame, ())

    Rx.combineLatest2(
        ticker |> Rx.Operators.startWith([0]),
        Input.getPlayerDirection  |> Rx.Operators.startWith([None])
    )
    |> Rx.Observable.subscribe(~next=update(game))
    |> ignore
}

let appendGameObject = (game: t, gameObject: GameObject.t) => {
    game.objects = Belt.Array.concat(game.objects, [gameObject])

    game.app
        -> Application.getStage
        -> Container.addChild(gameObject.sprite)
        -> ignore
}