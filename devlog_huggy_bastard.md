\[Devlog\] What I've Learned
============================

Welcome to my "devlog" or "What I've Learned" for my latest game: *Huggy
Bastard*.

Because the Play Store doesn't like it when you use the word "bastard"
in kid-friendly games, I decided to change the name to *I Wish You Good
Hug* on most platforms/websites.

Download the game here (for all platforms except iOS):
https://pandaqi.itch.io/i-wish-you-good-hug

But the original project title was a silly pun on Lucky Bastard, just so
you know.

Anyway, it's my second "one week game" (after the success of the first
one). This one was actually completed in less than a week! (However,
because of busy schedules, the *playtesting* and *marketing* and such
took longer than the previous game.)

In this article I'll explain **the biggest lessons I've learned**!

What's the idea?
----------------

Some time ago, I had the idea for a multiplayer hugging game (on
mobile). This is literally the single paragraph that I wrote down for
it:

"Players split into their own areas. Objective? Hug people. How? By
throwing them across the field *into the arms* of someone else ( = draw
characters with arms outstretched, a hug means two people are rotated
opposite each other)"

With that paragraph to go on, I started development!

Within a few hours of trying to draw a "hugging people" sprite, I
realized my best option was to use *teddy bears* and to change the grid
cells from square to circular.

(I tried square robots which could fit perfectly into each other. I
tried actual realistic people. I tried many things, but this worked
best.)

This was my "game bible", which I pinned to the top of the document, as
I always do:

-   **Objective?** You get points for each teddy bear that hugs a big
    bear.

-   **Input?** Moving and rotating.

-   **Core rule \#0:** "Hugging" always means two sprites are rotated
    opposite each other.

-   **Core rule \#1:** players can hold *one item*. It follows your
    rotation, as you'd expect. If it can interact with something, it
    will *auto-drop* onto the cell.

-   **Core rule \#2:** when you rotate, the cell you're on *also*
    rotates with you. (This is used by some special cells.)

I experimented with some other rules, but found them lacking for several
reasons:

**Discarded Rule: Step Counter.** Instead of "auto dropping", items
would show a number of steps. After moving that many squares, it
dropped.

Why was it discarded? Because it just wasn't fun. Yeah, it presented a
good puzzle, but it *wasn't fun* if all that was standing between you
and delivering a bear ... was the unfortunate fact that you had one step
too few (or too many).

**Discarded Rule: Bears are delivered if they hug *players***. Too easy.
Players can move and rotate completely freely, so it's not hard to do
this and won't stay interesting for longer than a few minutes.

**Discarded Rule: Side-hugs (or back-hugs)**. My code still supports
"hugging" at any other angle you want. But it just didn't add anything
to the game. (Why would it be more fun to rotate a bear to a *different*
specific angle?) Additionally, it was not intuitive and made things
needlessly complex. (Nobody hugs you from the side.)

Lesson \#1: Just make it
------------------------

Like most people, I like to make good decisions all the time. Before I
spend hours implementing something, I want to be sure it's the *best
choice* and *the right thing to do*.

You can't be sure. So don't even try. Just implement it.

The "discarded rules" above show this nicely. Those systems were the
*first ones* I ever implemented. I was certain my "step counter" idea
would be a core mechanic of the game, based on a number of good, logical
reasons.

But after playing around with it, it didn't work. So I switched
everything to auto drop (which took 1% of the time it took to implement
the step counter), and the game just instantly became better.

And in the end, I *did* end up bringing the step counter back for a few
other items (but not bears). Because it made more sense then, because
these items were not *crucial*, and the puzzle was actually a fun one.

Similarly, if you look at the spritesheet for this game, the cells are
all out of order. The first cells I created ended up being introduced
only halfway the game, or maybe even at the end.

As a last example: the concept of "shifting the map" is only introduced
in the last handful of levels. (What does this mean? For example: if you
shift a row +1, all cells in the row simply move 1 step to the right.)
But it was the *first thing* I made. Because I needed to be sure it was
possible, that the code supported it, and that it was easy to use.

*This always happens*. No matter how many games I make, no matter how
many good reasons I write down for a specific decision, I *cannot
predict the future*. So, after thinking for 30 minutes, I always tell
myself: "just make all these things, then we'll see what sticks"

Lesson \#2: The Best Way to Teach
---------------------------------

Teaching, in general, is something I'm very interested in. It shouldn't
be a surprise that I also think a lot about *how to teach a game in the
best way possible*.

With this game, a pattern showed itself quite clearly, which I'll
certainly use for more games.

Let's take **rotating** as an example. This is how it's taught in the
game:

-   First level: bears *automatically rotate* (every X seconds)

-   Second level: a special cell appears. Stand on it to *rotate*.

-   Third level: *press button X to rotate yourself.*

-   Fourth level: *hey, if you rotate, your cell rotates with you.*

-   (And later on: *cells that do something very special when rotated.*)

Every step is *the smallest possible learning curve*. But at the end,
you fully understand the input and output that rotation gives you.

If we generalize this, we get:

-   **Step 1: make it happen automatically, don't explain it**

-   **Step 2: make it happen at specific locations/times (which can be
    influenced or chosen by the player)**

-   **Step 3: make it happen when player *chooses* it themselves (with
    input)**

-   **Step 4+: make it happen *and then do something more advanced***

By the time you tell players "press A to rotate", they already *know*
what rotation means, and they *know* why and when to use it. They just
needed to learn the button.

Otherwise, if you don't do this, you need to present players with a big
tutorial image telling them: "Press A to rotate. Rotation means this and
this. It does that and that. And you can use it for X."

Which is completely overwhelming. And will, let's be fair, not be
understood or even *read* by most players.

To make sure the idea is clear, let's apply it to something else. Let's
say "backpack management" is a huge deal in your game.

-   **Step 1:** stuff randomly appears in your backpack, use it as you
    like

-   **Step 2:** when you stand on square X, your backpack opens, or you
    get something.

-   **Step 3:** press button Y to open/close your backpack

-   **Step 4+:** hey, if your backpack has three "water" in it, you can
    drown an opponent! (A weirdly specific rule, but I had to come up
    with something.)

Lesson \#3: They Are Not Board Games
------------------------------------

I come from the world of board games.

This is both a benefit (I think in terms of very simple, clear,
communicated rules) and a curse (I don't fully use the tools that video
games have to offer).

What do I mean? Well, computers can *remember all the rules* and *do
things automatically*, so that players don't have to.

I'm learning more and more about the value of **automatically doing
something** and how a game actually becomes easier to learn by trying to
tell players **less information**.

This game, just like the last one, improved significantly when I made
everything automatic. You auto-pickup objects when walking over them.
You auto-drop objects when they can interact with a special cell. When
possible, cells will auto-function, and you can only *work around it* or
*influence their specific timing/behavior*.

But the game doesn't tell you any of this. There's no tutorial saying:
"hey, if you want to pick up that bear, you need to walk towards it and
stand on the same cell!" Why? Because it's a very logical, intuitive
rule that most players will assume. Also because they can *discover* the
rule themselves within 10 seconds of playing the first level.

It's a fine balance to strike, but I lean towards *less is more*. Only
tell players things they really cannot gather from just playing the game
and trying to win. Or put a small reminder, or tip, on a later level to
*ensure* players get a piece of info. But don't give them walls of text,
or loads of tutorials, up-front that tell them *everything*.

Lesson \#4: The Three Mechanics
-------------------------------

I find that most games are very well balanced if they have *three main
systems* to learn.

For this game, those three are:

-   Rotating ( =\> Hugging)

-   Shooting ( =\> Receiving items)

-   Shifting the map

When I created the campaign, I wrote down step-by-step plans to *build
up* to a certain system. Doing that for all three systems, led to a
campaign of almost 30 levels, which has loads of variety and unique
systems, without being overwhelming. (At least, that's what I hope.)

For example, because *shifting* is such a difficult mechanic to master,
I already start building towards it around level 10.

-   You get a cell which can be changed by *standing on it and
    rotating*. (The alarm clock. It can be rewound to make the alarm go
    off later.)

-   Before that, you also get a cell that *shifts all beds*. (A more
    simple and direct way to use shifting.)

-   Before the full shifter is introduced, you get an *autoshifter*, and
    another *reminder* on how to interact with rotating cells.

-   But all of these additions are also fun, interesting mechanics on
    their own, so it's not like the whole game is a tutorial.

Guess what? That's the exact same way you handle a shifter! You stand on
it, and for each rotation you make, it shifts the row/column one step.

By building towards mechanics this way, I find that players have no
trouble at all learning even the most advanced of mechanics, and are
true huggy wizards near the end of the game.

But I don't think this would be possible with more than three "big"
mechanics. It would be too much. People forget the thing you're building
towards. People get overwhelmed and just ... put the controller down and
say "I don't know what I'm supposed to do anymore"

**Why [three]{.underline} mechanics though?** I think it has to do with
how they interconnect. If A changes B, B changes C, and C changes A
again ... you get a perfect loop!

The game is inherently balanced, because there's always a way to do what
you want, or to change the game state to something better. But it's not
a boring, predictable balance -- which it would be if there were only 1
or 2 systems. ("Oh, I can't do anything with system A? Then I must use
system B." Too easy.)

Lesson \#5: Atmosphere is everything
------------------------------------

I tend to overthink things and get too "brainy". After a few days, I had
a large set of interesting cells, mechanics, items, interactions, and
more for this game. They worked, they were challenging, they fit well
together, but ...

... when I looked at the game from a distance, I realized: *where has
the cute hugging theme gone? WHAT HAVE I BECOME!?*

The game was too "thinky", too abstract, too calculated.

So I spend the next few days mostly trying to get back the original
idea, that original warmth, the feeling of hugging. How? By ...

-   Adding all sorts of shiny particle effects (such as hearts appearing
    around bears that are hugging)

-   Adding more fitting animations. (For example, at first everything
    did the same "flash white" animation when something happened on that
    cell. But it's a game about hugging! So when two bears hug, it now
    plays a *squeeze tween*, as if they are just slightly squeezing each
    other in their arms.)

-   Making the colors a bit more bold and bright.

-   Adding many decorations, including cells that do absolutely nothing
    but just look good.

-   Using the right background music and UI elements. (At first, all
    buttons were just a default red box. Which was ... fine, but just
    didn't help the atmosphere at all.)

I ended up spending *more time* adding these tiny details, adding this
atmosphere, adding some warmth and life to the game ... than actually
developing the game itself (both the ideas and the execution).

But I think it's totally worth it and I should have spent even *more*
time.

The same game can be enjoyed 10x as much if it just *feels* fun and
warm, or not at all if it's bland and abstract. I have to learn, more
and more, that the value of a game is not just its actual, objective,
gameplay value (how good are the mechanics? Is it balanced?) ... it's
also the emotional *perceived* value (does it have an atmosphere of
plain old FUN?)

Lesson \#6: About star systems
------------------------------

I plan to write a longer article on this some day, but here's the
summary: **I used to be against "locking" a new level until players had
gathered enough stars, but I've changed my mind**.

In the first version of this game, you only had to play a level *once*
to unlock the next one. It didn't matter how many stars you got. It
didn't matter if you failed horribly.

Although this is very *nice* and removes any *frustration* from players
(because they want to progress, but instead need to replay the same
level) ... but turned out to be a bad idea in all other regards.

You see, if you didn't manage to get 1 or 2 stars in a level, that means
you *don't fully understand the new rule(s) yet* (or aren't trained
enough to use them quickly and get many points).

So, this is what happened: my players would play a level, get a bad
score, shrug it off, then continue with the next level ... and become
frustrated that they *didn't know what they were doing* and their
*scores were getting lower and lower*.

When I encouraged them to replay a level to get a better score, they
suddenly started to be come a bit more "serious" or "engaged". They
worked a little harder, made sure they understood what the new
rule/tile/mechanic did, so they could get that extra star.

That's the behavior you want! It's more fun for the players, provides a
bigger/more meaningful challenge, and ensures they don't get stuck later
on (when harder and harder levels appear).

As such, after these playtest sessions, I implemented the following
rule: **you need to earn at least 2 stars to unlock the next level**. So
far, this rule has worked *wonders* and provided just the right amount
of challenge.

From now on, whenever I make a game with such a "star system", I will do
this again. Because it simply makes a huge positive difference.

Conclusion
----------

Try out the game if it looks like something you'd enjoy!

Hopefully you find these lessons interesting and can apply them to your
own projects. And maybe I've even inspired you to do your own "one week
games"

Until the next devlog,

Pandaqi
