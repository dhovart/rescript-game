type t = {
  spriteContainer: PIXI.Container.t,
  entity: Entity.t,
  polygon: Polygon.t,
  controllable: bool,
  mutable behavior: option<Behavior.t>,
}

let make = (
  name,
  textureUrl,
  ~position=Vec2.make(0., 0.),
  ~acceleration=0.,
  ~controllable=false,
  ~polygon=?,
  ()
) => {
  let texture = PIXI.Texture.from(~source=#String(textureUrl), ())
  let texWidth = texture->PIXI.Texture.getWidth
  let texHeight = texture->PIXI.Texture.getHeight

  let sprite = PIXI.Sprite.create(texture)
  sprite->PIXI.Sprite.setAnchor(PIXI.ObservablePoint.create(~x=0.5, ~y=0.5, ~cb=() => (), ()))

  let spriteContainer = {
    open PIXI.Container
    let container = create()
    container->setPivot(sprite->PIXI.Sprite.getAnchor)
    container->addChild(sprite)->ignore
    container
  }

  let polygon = switch polygon {
  | Some(polygon) => polygon
  | None =>
    // use texture dimensions to define default object polygon (box)
    Polygon.make([0., 0., texWidth, 0., texWidth, texHeight, 0., texHeight])
  }

  let entity = Entity.make(~name, ~position, ~acceleration, ())

  {
    spriteContainer,
    entity,
    controllable,
    polygon,
    behavior: None,
  }
}

let appendDebugSprite = (gameObject: t, renderer: PIXI.Renderer.t) => {
  let bbox = gameObject.polygon.bbox
  let debugGraphics = {
    open PIXI.Graphics
    create()
    ->clear
    ->lineStyle(~color=0, ())
    ->beginFill(~color=0x3500FA, ~alpha=0.4, ())
    ->drawPolygon(#Array(gameObject.polygon.points))
    ->endFill
  }

  let brt = PIXI.BaseRenderTexture.create(
    ~options=PIXI.BaseRenderTexture.createOptions(~width=bbox.width, ~height=bbox.height, ()),
    (),
  )
  let texture = PIXI.RenderTexture.create(~baseRenderTexture=brt, ())

  renderer->PIXI.Renderer.render(
    ~displayObject=debugGraphics->Obj.magic,
    ~renderTexture=texture->Obj.magic,
    (),
  )

  let sprite = PIXI.Sprite.create(texture->Obj.magic)
  sprite->PIXI.Sprite.setAnchor(gameObject.spriteContainer->PIXI.Container.getPivot)
  gameObject.spriteContainer->PIXI.Container.addChild(sprite)->ignore
}

let render = (gameObject: t) => {
  open PIXI.Container
  gameObject.spriteContainer->setX(gameObject.entity.position.x)
  gameObject.spriteContainer->setY(gameObject.entity.position.y)
  gameObject.spriteContainer->setRotation(gameObject.entity.rotation)
  gameObject
}

let receiveInput = (gameObject, direction: option<Input.direction>) => {
  let {entity} = gameObject
  let {x, y} = entity.velocity
  let newVelocity: Vec2.t = switch direction {
  | Some(UP) => {x, y: y -. entity.acceleration}
  | Some(DOWN) => {x, y: y +. entity.acceleration}
  | Some(LEFT) => {x: x -. entity.acceleration, y}
  | Some(RIGHT) => {x: x +. entity.acceleration, y}
  | _ => {x, y}
  }
  entity.velocity = newVelocity
}

let update = (gameObject: t, input: option<Input.direction>) => {
  gameObject.entity.steeringForce = switch(gameObject.behavior) {
  | Some(behavior) => behavior->Behavior.getSteering(gameObject.entity)
  | None => Vec2.make(0., 0.)
  }
  if gameObject.controllable {
    receiveInput(gameObject, input)
  }
  gameObject.entity->Entity.update->ignore
  gameObject
}

let setBehavior = (gameObject, behavior) => {
  gameObject.behavior = Some(behavior)
  gameObject
}