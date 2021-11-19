# Verlet-Integration
A flying sheet with physics
I came across this in the mind blowing youtube series "Coding Math" by Keith Peters:
https://www.youtube.com/channel/UCF6F8LdCSWlRwQm_hfA2bcQ
You begin with a point or series of them. You give them a trajectory and make sure to flip it when they hit the boundaries of the screen. You then alter their trajectory with params like gravity, bounce and friction.
So far so good - you have points flying in space affected by mock physics. What makes this really interesting is the introduction of "sticks". Sticks are lines connecting 2 points, whose job is to make sure they maintain their distance. If the 2 defined points of a stick get too far from each other - the stick logic brings them closer to their original point. If they get too close - the stick pushes them apart.
The real magic comes when connecting sticks together. You can then create complex structures - anything you want really, and the sticks will maintain its original length.
This is particularly good for rag doll simulations, and also sheets.
I made a small sheet simulation using this method, but i wanted to add some more jazz to it.
I recently posted the video on triangle rasterzation and using the sticks method is a perfect candidate for this. There is nothing stopping from looking at the sticks wireframe as polygons and that's exactly what did.
It's remarkable how easily you can create something so complex with such a simple set of rules.
