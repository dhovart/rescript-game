type t = {
    points: array<float>
}

let make = points => { points, }

let findSmallest = xs => Belt.Array.reduce(xs, xs[0], Js.Math.min_float)
let findGreatest = xs => Belt.Array.reduce(xs, xs[0], Js.Math.max_float)

let pickByIndex = (xs, filter) =>
    Belt.Array.reduceWithIndex(xs, [], (acc, x, i) =>
        filter(i) ? acc : Belt.Array.concat(acc, [x]))

let getBox = polygon => { 
    let { points } = polygon
    let xs = pickByIndex(points, i => mod(i, 2) != 0)
    let ys = pickByIndex(points, i => mod(i, 2) == 0)

    let left = findSmallest(xs)
    let right = findGreatest(xs)

    let top = findSmallest(ys)
    let bottom = findGreatest(ys)

    [left, top, right, bottom]
}