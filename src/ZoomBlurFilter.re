class type _t = [@bs] {
    inherit PIXI.Filter._t;
};

type t = Js.t(_t);

[@bs.deriving abstract]
type createOptions = {
  [@bs.optional] strength: float,
  [@bs.optional] center: PIXI.Point.t,
  [@bs.optional] innerRadius: float,
  [@bs.optional] radius: float,
};

module Impl {

    [@bs.module "@pixi/filter-zoom-blur"][@bs.new]
    external create: (~options: createOptions) => t = "ZoomBlurFilter";
}

include PIXI.Filter.Impl;
include Impl;