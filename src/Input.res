type direction = UP | DOWN | LEFT | RIGHT

let getPlayerDirection = Rx.merge([
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