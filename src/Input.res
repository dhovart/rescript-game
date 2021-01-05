type key = UP | DOWN | LEFT | RIGHT
type keyboardAction = UP(bool) | DOWN(bool) | LEFT(bool) | RIGHT(bool)

type direction = {
  x: option<key>,
  y: option<key>
}

let setXDirection = (direction, key) => {
  ...direction,
  x: key
}

let setYDirection = (direction, key) => {
  ...direction,
  y: key
}

let playerDirection = Rx.merge([
  Rx.fromEvent(~target=Webapi.Dom.document, ~eventName="keydown") |> Rx.Operators.mapn(e =>
    switch e->Webapi.Dom.KeyboardEvent.key {
    | "ArrowUp" => Some(UP(true))
    | "ArrowDown" => Some(DOWN(true))
    | "ArrowLeft" => Some(LEFT(true))
    | "ArrowRight" => Some(RIGHT(true))
    | _ => None
    }
  ),
  Rx.fromEvent(~target=Webapi.Dom.document, ~eventName="keyup") |> Rx.Operators.mapn(e =>
    switch e->Webapi.Dom.KeyboardEvent.key {
    | "ArrowUp" => Some(UP(false))
    | "ArrowDown" => Some(DOWN(false))
    | "ArrowLeft" => Some(LEFT(false))
    | "ArrowRight" => Some(RIGHT(false))
    | _ => None
    }
  )
])
|> Rx.Operators.scan((acc, curr, _) =>
  switch curr {
  | Some(LEFT(isPressed)) => acc->setXDirection(isPressed ? Some(LEFT): None)
  | Some(RIGHT(isPressed)) => acc->setXDirection(isPressed ? Some(RIGHT): None)
  | Some(UP(isPressed)) => acc->setYDirection(isPressed ? Some(UP): None)
  | Some(DOWN(isPressed)) => acc->setYDirection(isPressed ? Some(DOWN): None)
  | None => acc
  }, {x: None, y: None}
)
|> Rx.Operators.distinctUntilChanged()
