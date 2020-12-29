type t = {
    spriteContainer: PIXI.Container.t,
    entity: Entity.t,
    polygon: Polygon.t,
    controllable: bool,
}

let make = (
    name,
    textureUrl,
    ~position=(0.,0.),
    ~controllable=false,
    ~polygon=?,
    ()) => {
    let texture = PIXI.Texture.from(~source=#String(textureUrl), ())
    let texWidth = texture -> PIXI.Texture.getWidth
    let texHeight = texture -> PIXI.Texture.getHeight

    let sprite = PIXI.Sprite.create(texture)
    sprite -> PIXI.Sprite.setAnchor(PIXI.ObservablePoint.create(~x=0.5, ~y=0.5, ~cb=() => (), ()))

    let spriteContainer = PIXI.Container.create()
    spriteContainer -> PIXI.Container.setPivot(sprite -> PIXI.Sprite.getAnchor)
    spriteContainer -> PIXI.Container.addChild(sprite) -> ignore

    let polygon = switch(polygon) {
        | Some(polygon) => polygon
        | None => {
            // use texture dimensions to define default object polygon (box)
            Polygon.make([
                0., 0.,
                texWidth, 0.,
                texWidth, texHeight,
                0., texHeight
            ])
        }
    }

    {
        spriteContainer,
        entity: Entity.make(~name=name, ~position=position, ()),
        controllable,
        polygon,
    }
}

let appendDebugSprite = (gameObject: t, renderer: PIXI.Renderer.t) => {
    let [left, top, right, bottom] = Polygon.getBox(gameObject.polygon)
    let debugGraphics = {
        open PIXI.Graphics
        create()
        -> clear
        -> lineStyle(~color=0, ())
        -> beginFill(~color=0x3500FA, ~alpha=0.4, ())
        -> drawPolygon(#Array(gameObject.polygon.points))
        -> endFill
    }

    let brt = PIXI.BaseRenderTexture.create(~options=PIXI.BaseRenderTexture.createOptions(
        ~width = right -. left,
        ~height = bottom -. top,
        ()), ())
    let texture = PIXI.RenderTexture.create(~baseRenderTexture=brt, ())

    renderer
        -> PIXI.Renderer.render(
            ~displayObject=debugGraphics->Obj.magic,
            ~renderTexture=texture->Obj.magic, ())

    let sprite = PIXI.Sprite.create(texture->Obj.magic)
    sprite -> PIXI.Sprite.setAnchor(gameObject.spriteContainer-> PIXI.Container.getPivot)
    gameObject.spriteContainer -> PIXI.Container.addChild(sprite) -> ignore
}

let render = (gameObject: t) => {
    let (px, py) = gameObject.entity.position
    let (ax, ay) = gameObject.entity.acceleration
    {
        open PIXI.Container
        gameObject.spriteContainer -> setX(px)
        gameObject.spriteContainer -> setY(py)
        gameObject.spriteContainer -> setRotation(Js.Math._PI /. 2. +. Js.Math.atan2(~y=ay, ~x=ax, ()))
    }
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