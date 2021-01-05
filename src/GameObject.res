
type t = {
  spriteContainer: PIXI.Container.t,
  entity: Entity.t,
  controllable: bool,
  behaviors: array<Behavior.t>,
}

let make = (
  name,
  textureUrl,
  ~kind,
  ~position=Vec2.make(0., 0.),
  ~acceleration=0.,
  ~maxSpeed=4.0,
  ~controllable=false,
  ~polygon=?,
  ~rotationFactor=1.,
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

  let entity = Entity.make(
    ~name,
    ~position,
    ~accelerationFactor=acceleration,
    ~rotationFactor,
    ~polygon,
    ~maxSpeed,
    ~kind,
    ())

  {
    spriteContainer,
    entity,
    controllable,
    behaviors: [],
  }
}

let setEntity = (gameObject, entity) => {...gameObject, entity}
let setBehaviors = (gameObject, behaviors) => {...gameObject, behaviors}

let appendDebugSprite = (gameObject: t, renderer: PIXI.Renderer.t) => {
  let bbox = gameObject.entity.polygon.bbox
  let debugGraphics = {
    open PIXI.Graphics
    create()
    ->clear
    ->lineStyle(~color=0, ())
    ->beginFill(~color=0x3500FA, ~alpha=0.4, ())
    ->drawPolygon(#Array(gameObject.entity.polygon.points))
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

let receiveInput = (gameObject, direction: Input.direction) => {
  if (!gameObject.controllable) {
    gameObject
  } else {
    let {entity} = gameObject
    let acceleration: Vec2.t = switch direction.y {
    | Some(UP) => Vec2.make(0., -.1.)
    | Some(DOWN) => Vec2.make(0., 1.)
    | _ => {x: 0., y: 0.}
    }->Vec2.add(switch direction.x {
    | Some(LEFT) => Vec2.make(-.1., 0.)
    | Some(RIGHT) => Vec2.make(1., 0.)
    | _ => {x: 0., y: 0.}
    })
    gameObject->setEntity(
      entity->Entity.setAcceleration(acceleration->Vec2.multiply(entity.accelerationFactor)))
  }
}

let updateEntity = (gameObject) => gameObject->setEntity(gameObject.entity->Entity.update)

let defineBehaviors = (gameObject, playerRef: ref<option<t>>, tree, camera) => {
  gameObject->setBehaviors(switch gameObject.entity.kind {
  | Player => []
  | Enemy =>
    [Behavior.SocialDistancing(gameObject.entity, tree, camera, 9.)]
    ->Belt.Array.concat(
      switch playerRef.contents {
      | Some(player) => [
          Behavior.CowardlySeek(gameObject.entity, player.entity, 7.),
        ]
      | None => []
      }
    )
  | _ => []
  })
}

let applyBehaviors = (gameObject) => {
  open Belt.Array
  gameObject->setEntity(gameObject.entity->Entity.applyForce(
      gameObject.behaviors->reduce(Vec2.make(0.0, 0.0), (acc, behavior) =>
        acc->Vec2.add(behavior->Behavior.getSteering(gameObject.entity))
    )
  ))
}

let update = (
  gameObject,
  input,
  playerRef,
  tree,
  camera,
) => {
 let object = gameObject
  ->defineBehaviors(playerRef, tree, camera)
  ->applyBehaviors
  ->receiveInput(input)
  ->updateEntity

  // this was supposed to be a pure function, check if we can set the player ref differently
  if gameObject.entity.kind === Entity.Player {
    switch playerRef.contents {
    | Some(player) => if (player === gameObject) {
      playerRef := Some(object)
    }
    | None => ()
    }
  }

  object
}