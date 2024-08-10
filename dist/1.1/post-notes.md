Just wanted to give a quick update on the game I am developing, Jack vs Zombies.
Thanks to some useful feedback from this subreddit I have been hard at work completely reworking my animation system and adding a combo mechanic to make combat more interesting.

The new version is up on the BBS: https://www.lexaloffle.com/bbs/?tid=142888

I would love it if people want to give it a try and share some feedback!

If people are interested I am happy to go into more details on the changes I made, or more information can be found on the BBS post.


# The animation system
For those who are curious, I had to completely rebuild by animation system as It used ot rely on sprites of the same size each time. This approach was easy to implement, simply make each frame fit in a 16x16 sprite and iterate over the sprites.

However, with such large sprites, I quickly ran out os space in the spritesheet. Looking around I found that I could probably mitigate the issue by doing some multi-cart wizardry or poke away somehow, but both solutions seemed complex.
It is a this point that I noticed a lot of repetition in my sprites, specifically many of my 16x16 sprites could be separated into two 8x16 sprites and simply reuse the head of the characters. But once you know this, why not go all the way and build an animation system that can draw frames made of an arbitrary number of sprites of variable sizes, and why not also implement a palette replacement configuration to add even more variation.

As you may imagine this spiraled out of control pretty quickly, leading me to redraw almost all animations and code a separate cart just to compose the parts of each frame.

Anyway, it works now, and I have plenty of space on my spritesheet. On the other hand, I keep exceeding the character limit so it looks like the next step should be some heavy code refactoring.