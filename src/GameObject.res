type t = {
  spriteContainer: PIXI.Container.t,
  entity: Entity.t,
  controllable: bool,
  behaviors: array<Behavior.t>,
}

let make = (
  id,
  textureUrl,
  ~kind,
  ~position=Vec2.make(0., 0.),
  ~acceleration=0.,
  ~maxSpeed=4.0,
  ~controllable=false,
  ~polygon=?,
  ~rotation=0.,
  ~rotationFactor=1.,
  ~velocityFactor=1.,
  (),
) => {
  let texture = PIXI.Texture.from(~source=#String(textureUrl), ())
  let texWidth = texture->PIXI.Texture.getWidth
  let texHeight = texture->PIXI.Texture.getHeight

  let polygon = switch polygon {
  | Some(polygon) => polygon
  | None =>
    // use texture dimensions to define default object polygon (box)
    Polygon.make([0., 0., texWidth, 0., texWidth, texHeight, 0., texHeight])
  }

  let sprite = PIXI.Sprite.create(texture)
  let spriteContainer = {
    open PIXI.Container
    let container = create()
    container->setPivot(
      PIXI.ObservablePoint.create(
        ~x=polygon.bbox.width /. 2.,
        ~y=polygon.bbox.height /. 2.,
        ~cb=() => (),
        (),
      ),
    )
//    container->addChild(sprite)->ignore
    container
  }

  let entity = Entity.make(
    ~id,
    ~position,
    ~rotation,
    ~accelerationFactor=acceleration,
    ~rotationFactor,
    ~velocityFactor,
    ~polygon,
    ~maxSpeed,
    ~kind,
    (),
  )

  {
    spriteContainer: spriteContainer,
    entity: entity,
    controllable: controllable,
    behaviors: [],
  }
}

let setEntity = (gameObject, entity) => {...gameObject, entity: entity}
let setBehaviors = (gameObject, behaviors) => {...gameObject, behaviors: behaviors}

let appendDebugSprite = (gameObject: t) => {
  let debugGraphics = PIXI.Graphics.create()
  let debugGraphics = gameObject.entity.polygon->Polygon.draw(debugGraphics->Obj.magic)
  gameObject.spriteContainer->PIXI.Container.addChild(debugGraphics)->ignore
  // let text = PIXI.Text.create(
  //   ~text=Belt.Int.toString(gameObject.entity.id),
  //   ~style=PIXI.TextStyle.create(
  //     ~style=PIXI.TextStyle.createStyleOptions(~fill=0xFFFFFF, ~fontWeight="bold", ()),
  //     (),
  //   ),
  //   (),
  // )
  // gameObject.spriteContainer->PIXI.Container.addChild(text)->ignore
}

let render = (gameObject: t) => {
  open PIXI.Container
  gameObject.spriteContainer->setX(gameObject.entity.position.x)
  gameObject.spriteContainer->setY(gameObject.entity.position.y)
  gameObject.spriteContainer->setRotation(gameObject.entity.rotation)
  gameObject
}

let receiveInput = (gameObject, direction: Input.direction, camera: Camera.t) => {
  if !gameObject.controllable {
    gameObject
  } else {
    let {entity} = gameObject
    let acceleration: Vec2.t = switch direction.y {
    | Some(UP) => Vec2.make(0., -1.)
    | Some(DOWN) => Vec2.make(0., 1.)
    | _ => {x: 0., y: 0.}
    }->Vec2.add(
      switch direction.x {
      | Some(LEFT) => Vec2.make(-1., 0.)
      | Some(RIGHT) => Vec2.make(1., 0.)
      | _ => {x: 0., y: 0.}
      },
    )->Vec2.transform(~rotation=-.camera.rotation, ())
    gameObject->setEntity(
      entity->Entity.setAcceleration(acceleration->Vec2.multiply(entity.accelerationFactor)),
    )
  }
}

let updateEntity = (gameObject, tree, camera, debugGraphics) => {
  let bbox = gameObject.entity->Entity.getBBox(~scale=2., ())
  let neighbours =
    tree
    ->QuadTree.bboxQuery(bbox, camera, ())
    ->Belt.Array.keep(entity => !(entity->Entity.eq(gameObject.entity)))
  gameObject->setEntity(gameObject.entity->Entity.update(neighbours, debugGraphics))
}

let defineBehaviors = (gameObject, playerRef: ref<option<t>>, tree, camera) => {
  gameObject->setBehaviors(
    switch gameObject.entity.kind {
    | Player => []
    | Enemy =>
      [
        Behavior.SocialDistancing(gameObject.entity, tree, camera, 15.),
        Behavior.CollisionAvoidance(gameObject.entity, tree, camera, 15.)
      ]
    ->Belt.Array.concat(
      switch playerRef.contents {
      | Some(player) => [
          Behavior.CowardlySeek(gameObject.entity, player.entity, 7.),
        ]
      | None => []
      }
    )
    | _ => []
    },
  )
}

let applyBehaviors = gameObject => {
  open Belt.Array
  gameObject->setEntity(
    gameObject.entity->Entity.applyForce(
      gameObject.behaviors->reduce(Vec2.make(0.0, 0.0), (acc, behavior) =>
        acc->Vec2.add(behavior->Behavior.getSteering(gameObject.entity))
      ),
    ),
  )
}

let update = (gameObject, input, playerRef, tree, camera, debugGraphics) => {
  let object =
    gameObject
    ->defineBehaviors(playerRef, tree, camera)
    ->applyBehaviors
    ->receiveInput(input, camera)
    ->updateEntity(tree, camera, debugGraphics)

  // this was supposed to be a pure function, check if we can set the player ref differently
  if gameObject.entity.kind === Entity.Player {
    switch playerRef.contents {
    | Some(player) =>
      if player === gameObject {
        playerRef := Some(object)
      }
    | None => ()
    }
  }

  object
}
