A small game made with ReScript. Super early stage

TODO

## Fixes

- less naive collision avoidance behavior

## Refactoring

- Get rid of GameObject.
- Create a map of sprites with the entities id as keys
- Collision detection functions should be at the shape level, not at the entity level
- Framerate independent updates

## Features

Enable creating an entity shape by assembling shapes instead of a single polygon

### Define actual gameplay

- Based on free exploration
- Creatures are peaceful, only fight back if agressed
- Explore "travelling into the past" by storing game state each X frame in a linked list and interpolating between states

## Define a graphic system

- Limited palette
- Simple geometric shapes
- Animated seamless patterns using frag shaders

## Define creature motion

Go for something organic
