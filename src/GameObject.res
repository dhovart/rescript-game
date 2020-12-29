open PIXI

type t = {
    sprite: Sprite.t,
    entity: Entity.t,
    controllable: bool,
}

let make = (textureUrl, ~position=(0.,0.), ~controllable=false, ()) => {
    let texture = Texture.from(~source=#String(textureUrl), ())
    let sprite = Sprite.create(texture)
    sprite -> Sprite.setAnchor(ObservablePoint.create(~x=0.5, ~y=0.5, ~cb=() => (), ()))
    sprite -> Sprite.setX(texture -> Texture.getWidth /. 2.)
    sprite -> Sprite.setY(texture -> Texture.getHeight /. 2.)
    sprite -> Sprite.setPivot(sprite -> Sprite.getAnchor)

    { sprite, entity: Entity.make(~position=position, ()), controllable }
}

let render = (gameObject: t, (cx, cy): Vec2.t) => {
    let (px, py) = gameObject.entity.position
    let (ax, ay) = gameObject.entity.acceleration
    gameObject.sprite -> Sprite.setX(cx +. px)
    gameObject.sprite -> Sprite.setY(cy +. py)
    gameObject.sprite -> Sprite.setRotation(Js.Math._PI /. 2. +. Js.Math.atan2(~y=ay, ~x=ax, ()))
}

let receiveInput = (gameObject: t, direction: option<Input.direction>) => {
    let { entity } = gameObject 
    let (ax, ay) = entity.acceleration
    let newAcceleration = switch(direction) {
    | Some(UP) => (ax, ay -. entity.accelIncrease)
    | Some(DOWN) => (ax, ay +. entity.accelIncrease)
    | Some(LEFT) => (ax -. entity.accelIncrease, ay)
    | Some(RIGHT) => (ax +. entity.accelIncrease, ay)
    | _ => (ax,ay)
    }
    entity.acceleration = newAcceleration
}

let update = (gameObject: t, input: option<Input.direction>) => {
    Entity.update(gameObject.entity)
    if (gameObject.controllable) {
        receiveInput(gameObject, input)
    }
}