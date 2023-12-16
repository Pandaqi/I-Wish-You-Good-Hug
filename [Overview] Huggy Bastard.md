# Huggy Bastard

(Alternative names: Good Hug, Trust Hug)

## Objective

Randomly, small (teddy) bears appear on the map. Your goal is to "deliver" them.

**How to deliver bears?** By making them hug a big parent (teddy) bear.

**How to hug?** Well, the same as in real life. Two bears can only hug if they look at each other (and have their arms outstretched towards each other).

**But beware!** If a bear flies out of bounds, it is lost and incurs a penalty.

## Input

You control a single **character** on the field: this is a big parent bear. (Although these might get different colors, to make them distinct?)

You can **move** and **rotate.**

-   **Moving** will simply move your character (+its backpack) in the chosen direction

-   **Rotating** will rotate your character. If your current cell has content, that is also rotated. Otherwise, the cell itself is rotated (if that's possible).

Controls

-   **Moving =** keys/joystick (PC) or swiping (touchscreen)

-   **Rotating** = hold the "rotate" button and use move input to aim (PC) or make a rotate gesture (touchscreen)

When it moves onto a square that has something, it **picks it up**.

-   Each character has space for **one thing**. (They will hug that thing when they hold it.)

-   Items have a fixed number of steps. When they run out, it automatically drops.

-   Many items also require you to *hug it*. Otherwise you just ignore it.

-   When it encounters something else, it will **drop the old thing** (and then pick it up).

**Old idea:** your backpack can switch between "swap new items" or "ignore new items" using a special cell.

## Throwing bears

The field will have multiple **trampoline squares**. These are set to a **timer**. Whenever the timer runs out, it will **throw its content** in the given direction.

(Of course, the timer resets after that. And if it has no content, nothing happens.)

## Special Items

The following special items are in the game.

Crucial

-   The (tiny) teddy bear. Can only be picked up by hugging, has max-steps.

Inbetweeners

-   Cacti => Give minus points when someone hugs/collects them.

-   Hole => Use this to throw stuff away, such as annoying cacti.

-   Pillow => catches flying bears

-   Heart => give to big bear to increase its point value. Penalty for removing it

-   Gift => if all players have held it, you get loads of points. Penalty for removing it.

## Special Squares

The following special squares are in the game.

Crucial

-   Trampoline => throws bears

-   Big bears => accepts tiny teddy bears. (Can only be rotated, not moved/picked up.)

    -   Only if they hug each other! This is what gives you points.

    -   Players can also only enter if they hug.

-   Trees/Bamboo/Sticks => a temporary stop point for bears.

-   Shifter => shifts the whole column/row each time you rotate (while standing on it).

    -   For now, there are no restrictions. You can always do this, no matter who is standing on it, etc.

-   Divider => empty space that cannot be entered. Can be fixed into place (so it even stays in the center after shifting a row/column). Separates the players.

-   Score => simply a cell that displays the score, because I like how clean it looks without UI.

Less crucial

-   Conveyor Belt => continually moves its contents in the direction shown.

## Campaign

**Level 1**

-   Controls: Move with joystick. When you hold button, you can rotate instead.

-   New rule: Picking up stuff! You can only pick up a bear, by hugging it.

-   Objective: deliver teddy bears to their bed.

**Things changed:**

-   The concept of \"maximum steps\" isn\'t introduced yet. When you pass over a bed with a bear in your hands, it just immediately drops it.

-   There is no way to cross player areas yet, so there should be a good balance of bears + beds in each half.

-   Bears *auto rotate* every few seconds.

**Level 2**

-   New Cell: Rotator => rotates you a quarter step when you step on it

-   This means bears can **stop** auto rotating!

**Level 3**

-   New Cell: Shooter => when you step on it, with a bear in your hands, the bear *shoots* *away* in the direction you're facing.

-   (New Rule: bears *wrap* around the field.)

**Remark:** beds are placed *in line* with shooters. (Just like trampolines later.)

**Level 4**

-   New Control: When X is held, you **rotate** your character. (Using the same keys/stick as you use for *moving*.)

**Remark:** of course, the *rotator* cell is removed by now

**Level 5**

-   Updated Objective: From now on, you can only deliver teddy bears to beds if their head lands on their pillow.

-   New Rule: A cell automatically rotates with you, whenever \_you\_ stand on it and rotate.

-   New Rule: You cannot enter beds while holding something.

**Level 6**

-   New Item: Cactus. If you pick them up (or they hit you when flying), you get a penalty of -1 point!

**Level 7**

-   New Cell: Hole. Anything dropped or thrown into it, is immediately removed. Removing good things (such as bears) gives a penalty, removing bad things (such as cacti) gives bonus points.

**Level 8**

-   New Cell: Bed Mover. When stepped on, it moves *all beds* in the direction visible (if possible).

**Level 9**

-   New Cell: teleport. Moves your player to the teleport with next number. (Wraps back to the first number if you reach the maximum.)

**Level 10**

-   Cell Update: from now, teleports have a *timer*. It only teleports its content when it reaches 0 ( = all hourglasses are gone).

**Level 11**

-   New Cell: Alarm clock. When it goes off, any item ON or ADJACENT to it, is removed. (Same as the Hole.)

**Level 12:**

-   Cell Update: you can *wind up* the alarm, to postpone it going off, by standing on it and rotating *clockwise*.

-   (General rule: all timed cells can be rewound.)

**Remark:** ALL timed cells can be rewind. But they can NOT be "unrewound" ( = sped up). It's a nice idea, but also defeats the whole purpose, as there's no penalty to doing so.

**Level 13**

-   New Rule: Trampolines have a timer. Whenever it runs out, it SHOOTS whatever is on it in the direction of the arrow. (And then the timer starts again.)

-   (Remember! You can rotate cells by standing on them and rotating yourself!)

**Level 14**

-   New Item: Pillow.

-   When a bear hits a pillow, it stops flying! But the pillow is removed.

-   When you grab a pillow, a number of paws appear. For each action you take (move or rotate), one paw is removed. All paws gone? You drop the pillow!

-   (Pillows also give you +1 point just for holding it.) \<= don't mention

**Level 15**

-   Updated Objective: It turns out beds were not the final dream of bears. They actually dreamt of hugging. From now on, teddy bears simply want to hug a big bear!

-   Just like beds, players can't enter a big bear cell while holding something, and bears are only delivered if they \_hug\_ their parents.

**Remark:** temporarily, trampolines line up with the bears again. (Because the BedMover is gone, because beds are gone, we can't deliver stuff any other way.)

**Level 16**

-   New Rule: from now on, players can also only enter a big bear cell if they \_hug\_ the bear.

**Level 17**

-   New Rule: Bears can't wrap the field anymore. Instead, when they fly out of bounds, they are removed and give you a point penalty!

**Level 18**

-   New Cell: Autoshifter. When you enter this cell, you shift the whole *row* or *column* one step. (Depending on what you can see, just like the BedMover.)

**Remark:** trampolines don't line up anymore! Nothing lines up! Because you can, potentially, move anything anywhere.

**Level 19**

-   New Cell: Store (a four-way-cell) Depending on how you enter it, you get either

```{=html}
<!-- -->
```
-   A pillow

-   A cactus

-   Minus points

-   A trampoline, but the cell is destroyed.

**Level 20**

-   New Item: Heart. Drops after 4 steps. When dropped in hands of big bear, they are worth 4 more points (when you give them a bear).

-   (Each star around them indicates 4 bonus points.)

-   You are penalized for removing it.

**Level 21**

-   New Item: Gift. For each unique player that holds it, you get 5 points. (Once everyone has held it, it disappears.)

-   You are penalized for removing it yourself. Cannot wrap around the level.

**Level 22**

-   New Cell: Gift Wrapper. If you rotate one circle clockwise, you get a gift. If you rotate one circle counterclockwise, you get a heart.

**Remark:** remove auto-spawning of hearts and gifts, of course.

**Level 23**

-   New Cell: Shifter. *But only the row type, to keep it simple*.

**Level 24**

-   Cell Update; Shifter. *Now it can be either row or column*.

**Remark:** remove autoshifter again

**Level 25**

-   New Cell: Bamboo. When a bear enters the cell (in whatever way), it immediately stops and clings to the bamboo.

**Remark:** Store has been removed. (Because pillows would otherwise do the same as bamboo.) Some items autospawn again.

**Level 26**

-   New Cell: Stepchanger. (Depending on how you enter, it increases/decreases your steps.) Not an amazing addition, but it's fine.

**Level 27**

-   New Cell: Conveyor Belts

-   Has a timer. When done, simply moves its item to the next cell, following its direction.

-   (If it can't drop there, it will fly over it until the first cell where it CAN drop.)

**Remark:** trampolines are removed to make place for these. What are the advantages/differences?

-   They are faster. (Shorter timer, fewer steps.)

-   They are more controlled. (Only one space at a time in specific direction.)

-   There are more of them. (To make up for lack of distance.)

## Remarks

**TO DO:** Should there be a TIMER on delivering?? Should *big bears* get hourglasses around them, and when they run out, it goes away and you get a penalty?

-   Advantage: adds pressure, more chaos, was in the original idea, seems fitting

-   Disadvantage: bit too stressful, can lead to "nah not gonna make it anyway", doesn't fit with cute theme

**TO DO:** It feels like we're not using *items* and *step system* enough. (Also, the *step changer* is gone at the moment.)

**TO DO:** It feels like we're not using "cell does what is visible"-mechanic and "timing"-mechanic enough. (The idea of a *trust hug* is a bit gone in the current design ... )

## Deprecated

New Rule: anytime you drop a bear, it automatically flies in the direction your arms are pointing. (**Remark:** of course, the *shooter* cell will be gone by now.)

## Old Idea

A real-time puzzle game about timing and trust. Cooperative, 2 players.

A better name: **HUGGY BASTARD!**

**The Gimmick?** People will appear on your field. They have a timer. Before it runs out, they must get a hug.

How to do that? Well, you swipe them across the field to the other player. *They should have someone ready to receive him*.

**Goal?** Don't die within the time frame. Earn as many points as possible.

**Levels?** Randomly generated on the fly. Puzzle elements should be engaging, but also not *too* hard to solve, as you must do so in real-time (under pressure).

Why do they exist though? For variety, but mostly *cooperation*. Eyes on your own field, must work together.

**Single Player Mode?** Yes. But then, the hug receivers should be placed by the computer (with timers), there should be harder puzzles and more unknown information.
