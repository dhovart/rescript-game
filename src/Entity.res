type kind = Enemy | Player | Obstacle | Bullet

type t = {
  id: int,
  velocity: Vec2.t,
  acceleration: Vec2.t,
  accelerationFactor: float,
  position: Vec2.t,
  rotation: float,
  maxSpeed: float,
  maxSteeringForce: float,
  polygon: Polygon.t,
  kind: kind,
  rotationFactor: float,
  velocityFactor: float,
}

let make = (
  ~id,
  ~kind,
  ~velocity=Vec2.make(0., 0.),
  ~position=Vec2.make(0., 0.),
  ~maxSpeed=6.,
  ~acceleration=Vec2.make(0.9, 0.0),
  ~accelerationFactor=0.3,
  ~maxSteeringForce=1.0,
  ~rotation=0.0,
  ~polygon=Polygon.make([]),
  ~rotationFactor=1.,
  ~velocityFactor=1.,
  (),
) => {
  id,
  kind,
  velocity,
  velocityFactor,
  position,
  maxSpeed,
  acceleration,
  accelerationFactor,
  maxSteeringForce,
  rotation,
  rotationFactor,
  polygon,
}

let setVelocity = (entity, velocity) => {...entity, velocity: velocity}
let setAcceleration = (entity, acceleration) => {...entity, acceleration: acceleration}
let applyForce = (entity, force) => entity->setAcceleration(entity.acceleration->Vec2.add(force))
let eq = (entity, other) => compare(entity.id, other.id) === 0

type collisionInfo = CollisionInfo(Vec2.t, float) // axis, overlap
type collisionResult = CollisionResult(bool, option<collisionInfo>) // separated?, info

let getProjectedMinMax = (polygon: Polygon.t, axis, translation, rotation, debugGraphics) => {
    open Belt.Array
    let projectedPoints = polygon.points->map(vec => vec
      ->Vec2.transform(~rotation, ())
      ->Vec2.add(translation)
      ->Vec2.dot(axis)
    )

    (projectedPoints->Utils.findMin, projectedPoints->Utils.findMax)
}

let isCollidingAccordingToEntityNormals = (entity, otherEntity, normals, debugGraphics) => {
  normals->Belt.Array.reduce(CollisionResult(false, None), (collisionResult, axis) => {
    let separated = switch collisionResult {
      | CollisionResult(true, _) => true
      | CollisionResult(false, _) => false
    }
    if separated {
      CollisionResult(true, None)
    } else {
      let (minEntity, maxEntity) =
        entity.polygon->getProjectedMinMax(axis, entity.position, entity.rotation, debugGraphics)
      let (minOther, maxOther) =
        otherEntity.polygon->getProjectedMinMax(
          axis,
          otherEntity.position,
          otherEntity.rotation,
          debugGraphics
        )
        
      if !((minEntity < maxOther && minEntity > minOther) || (minOther < maxEntity && minOther > minEntity)) {
        CollisionResult(true, None)
      } else {
        let overlap = Js.Math.abs_float(
          maxEntity > minOther ? maxEntity -. minOther : minEntity -. maxOther,
        )

        // open PIXI.Graphics
        // let overlapV = axis->Vec2.normalize->Vec2.multiply(overlap)
        // debugGraphics->lineStyle(~color=0xFF0000, ~width=2., ())->ignore
        // debugGraphics->moveTo(~x=0., ~y=0.)->lineTo(~x=overlapV.x, ~y=overlapV.y)->ignore

        switch collisionResult {
        | CollisionResult(separated, Some(CollisionInfo(previousAxis, minOverlap))) =>
          if (minOverlap < overlap) {
            CollisionResult(false && separated, Some(CollisionInfo(previousAxis, minOverlap)))
          } else {
            CollisionResult(false && separated, Some(CollisionInfo(axis, overlap)))
          }
        | CollisionResult(_, None) => CollisionResult(false, Some(CollisionInfo(axis, overlap)))
        }
      }
    }
  })
}

let getCollisionInfo = (entity, otherEntity, debugGraphics) => {
  if entity->eq(otherEntity) {
    None
  } else {
    let collisionResultAccordingToEntityAxis = isCollidingAccordingToEntityNormals(
      entity,
      otherEntity,
      entity.polygon.normals->Belt.Array.map(Vec2.transform(_, ~rotation=entity.rotation, ())),
      debugGraphics
    )
    let collisionResultAccordingToOtherEntityAxis = isCollidingAccordingToEntityNormals(
      entity,
      otherEntity,
      otherEntity.polygon.normals->Belt.Array.map(
        Vec2.transform(_, ~rotation=otherEntity.rotation, ()),
      ),
      debugGraphics
    )
    switch (collisionResultAccordingToEntityAxis, collisionResultAccordingToOtherEntityAxis) {
    | (
        CollisionResult(false, Some(CollisionInfo(axisA, overlapA))),
        CollisionResult(false, Some(CollisionInfo(axisB, overlapB)))
      ) => {
        if (overlapA < overlapB) {
          Some(CollisionInfo(axisA, overlapA))
        } else {
          Some(CollisionInfo(axisB, overlapB))
        }
      }
    | _ => None
    }
  }
}

let update = (entity, neighbours, debugGraphics) => {
  let displacement = neighbours->Belt.Array.reduce(Vec2.make(0., 0.), (displacement, neighbour) => {
    let collisionInfo = entity->getCollisionInfo(neighbour, debugGraphics)
    switch collisionInfo {
    | Some(CollisionInfo(axis, overlap)) => {
      Js.log(("collision!", axis, overlap))
      displacement->Vec2.add(axis->Vec2.multiply(overlap *. -1.))
    }
    | None => displacement
    }
  })

  let desiredVelocity =
    entity.velocity->Vec2.add(entity.acceleration)->Vec2.multiply(0.98)->Vec2.limit(entity.maxSpeed)
  let velocity = entity.velocity->Vec2.lerp(desiredVelocity, entity.velocityFactor)
  let desiredRotation = Js.Math._PI /. 2. +. Js.Math.atan2(~y=velocity.y, ~x=velocity.x, ())
  let rotation = desiredRotation
  let position = Vec2.lerp(entity.position, entity.position->Vec2.add(displacement), 0.8)
  let position = position->Vec2.add(velocity)
  {
    ...entity,
    velocity,
    rotation,
    position,
    acceleration: Vec2.make(0., 0.),
  }
}

let getBBox = (entity, ~scale=1., ()) => {
  let bbox = entity.polygon.bbox
  ->BBox.getRotatedBBoxBBox(entity.rotation, scale)
  bbox->BBox.setTopLeft(entity.position
    ->Vec2.substract(Vec2.make(bbox.width/. 2., bbox.height/. 2.)))
}
