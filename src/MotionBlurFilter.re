class type _t = [@bs] {
    inherit PIXI.Filter._t;
};

type t = Js.t(_t);

module Impl {
    open PIXI
 
    [@bs.module "@pixi/filter-motion-blur"][@bs.new]
    external create: (
      [@bs.unwrap] [
        | `Point(Point.t)
        | `ObservablePoint(ObservablePoint.t)
        | `Array(array(float))
      ], ~kernelSize: int=?, ~offset: float=?, unit) => t = "MotionBlurFilter";
}

include PIXI.Filter.Impl;
include Impl;