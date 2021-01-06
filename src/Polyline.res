type t = array<float>

let getBBox = points => {
  let xs = points->Utils.filterByIndex(i => mod(i, 2) != 0)
  let ys = points->Utils.filterByIndex(i => mod(i, 2) == 0)
  let left = Utils.findMin(xs)
  let right = Utils.findMax(xs)
  let top = Utils.findMin(ys)
  let bottom = Utils.findMax(ys)
  let size = Vec2.make(right -. left, bottom -. top)
  let pos = Vec2.make(left, top)->Vec2.substract(size->Vec2.divide(2.))
  BBox.make(~topLeft=pos, ~width=size.x, ~height=size.y, ())
}

let getPointsAsVec2 = points => {
  open Belt.Array
  points->reduceWithIndex([], (vec2s, point, i) => {
    vec2s->concat(
      if mod(i, 2) == 0 {
        []
      } else {
        switch (points->get(i - 1), point) {
        | (Some(x), y) => [Vec2.make(x, y)]
        | _ => []
        }
      },
    )
  })
}

let getSegments = points => {
  open Belt.Array
  let points = points->getPointsAsVec2
  let first = switch (points->get(0), points->get(1)) {
  | (Some(a), Some(b)) => Some([a, b])
  | _ => None
  }
  points->reduceWithIndex([], (segments, point, i) => {
    segments->concat(
      if mod(i, 2) == 0 {
        []
      } else {
        let previousToCurrent = switch points->get(i - 1) {
        | Some(previous) => Some([previous, point])
        | _ => None
        }
        let currentToNext = switch points->get(i + 1) {
        | Some(next) => Some([point, next])
        | _ => None
        }
        switch (previousToCurrent, currentToNext) {
        | (Some([a, b]), Some([c, d])) => [Segment.make(a, b), Segment.make(c, d)]
        | (Some([a, b]), None) => switch first {
            | Some([c, _]) => [Segment.make(a, b), Segment.make(b, c)]
            | _ => []
        }
        | _ => []
        }
      },
    )
  })
}

let getNormals = points => {
  points->getSegments->Belt.Array.map(Segment.getNormal(_, ~clockwise=true, ()))
}
