# racket-optics
optics (lenses, prisms, traversals, isos) in racket

# Lens

A [Lens S T] represents a getter and a setter for a target T within a structure S. For example, you could make a lens out of a getter function and a setter function for a field of a struct

Lenses support two primitive operations:
- `(lens-view l s)`, which extracts the target from the structure `s`
- `(lens-set l t s)`, which sets the target within `s` to `t`

# Iso

An [Iso A B] represents an isomorphism between two types A and B. Two types are considered isomorphic if you can convert between them both ways. In other words, they are just different representations of the same information. For example, if I have two representations of a rectangle, one containing the top-left position and the bottom-right position, and another containing the top-left position, the width, and the height, those two representations are isomorphic. I can convert between them without losing any information. They are mostly useful when composed with other optics to express a transformation of one structure in terms of an equivalent one that is more suited to the transformation. In our rectangle example, if I wanted to make a rectangle wider and I was working with the top-left bottom-right representation, I could compose the iso between them with the width lens of the second representation to modify the width, despite our rectangle not having a width field. This just abstracts the process of converting to a well-suited representation, making a modification, and then converting back.

Isos support two primitive operations:
- `(iso-forward i a)`, which converts from `A` to `B`
- `(iso-backward i b)`, which converts from `B` to `A`

For example, you might define an Iso `string<->symbol`, which converts from string to symbol in the forward direction, and the inverse in the backward direction

# Traversal

A [Traversal S T] is similar to a lens, except where a lens has exactly one target, a traversal may contain many targets, or none at all. For example, if you have a list of posns, you might want to update all the x-coordinates at once. One way to accomplish this would be to define a traversal which targets each posn's x-coordinate. This is sort of like `map`, except it can target values deep within a structure, and/or only parts of a structure. You can also collect the targets, which you cannot do in a map

Traversals support two primitive operations:
- `(traversal-transform t s f)`, which applies f to each target
- `(in-traversal t s)`, which iterates over each target

The second primitive operation of a traversal is a tranformation, not a setter. With a lens, you can implement a `lens-transform` operation using `lens-view` and `lens-set`. However, since there is no `traversal-get`, you cannot use the same trick. When there are multiple targets, an updater is strictly more general than a setter. An updater can be applied to each target and do different things depending on each target's value. In contrast, a would have to do the same thing to each target. Also, if there are no targets, trying to get and set makes even less sense.

# Prisms

A [Prism S T] is similar to a lens, but has exactly 0 or 1 target. For example, if I have a little arithmetic expression language with addition, multiplication, numbers, and variables, I might make a prism for the left sub-expression of an arithmetic expression. In the number and variable cases, there'd be zero targets. In the addition and multiplication cases, there'd be one target.
This is sort of like a first-class pattern match on a value

Prisms support two primitive operations:
- `(prism-view p s)`, which returns either the target or #f if it doesn't exist. TODO something like maybe
- `(prism-transform p s f)`, which applies f to the target, if it exists

The primitive operation is a transform for a similar reason to traversals.


