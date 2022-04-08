An abandoned game project from 2021. More of a game engine prototype than anything else.

It let me get more familiar with the (really nice) ReScript language, quadtrees, steering behaviors and collision detection using the Separating Axis "Theorem".

It's not performant at all because I decided to do everything in an immutable way (it's dumb but it seemed like a proper approach then, working with a functional language...), creating new objects rather than modifying existing ones and as such giving a lot of work to the garbage collector.

[Video](https://www.youtube.com/watch?v=GMCUAwcXoco) on youtube.
