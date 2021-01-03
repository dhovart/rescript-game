open Belt.Array

let findMin = xs => xs->reduce(xs[0], Js.Math.min_float)
let findMax = xs => xs->reduce(xs[0], Js.Math.max_float)
let filterByIndex = (xs, filter) =>
  xs->reduceWithIndex([], (acc, x, i) => filter(i) ? acc : acc->concat([x]))
let empty = xs => xs->length === 0
let head = xs => xs[0]
let tail = xs => xs->slice(~offset=1, ~len=xs->length)
let lerp = (start, end, percent) => start +. percent *. (end -. start)