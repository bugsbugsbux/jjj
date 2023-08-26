<!--
<head><meta http-equiv="refresh" content="5"/></head>
<style>
pre { background: #dddddd; padding: 1em; overflow: auto; }
code { background:#dddddd; }
</style>
-->

- Status: Work in Progress
- J versions: 9.4.2,

Found anything wrong? File an issue at
<https://github.com/herrvonvoid/jjj/issues>.

# An overview of J

An introduction to the J programming language that gets to the point. It
is intended for those with (some) programming experience, but others
should be mostly fine after looking up some basic programming terms like
function, argument, class, instance, inheritance, statement, expression,
etc.

This is not a reference: Read the whole thing and try the examples.
Abbreviations and covered builtins are listed in the appendix.

Important links:

- Project Homepage: <https://jsoftware.com>
- Try J online: <https://jsoftware.github.io/j-playground/bin/html2/>
- **All builtin operators**, with links to their wiki pages:
  <https://code.jsoftware.com/wiki/NuVoc>
- Good old wiki:
  <https://www.jsoftware.com/help/dictionary/contents.htm>

#### History:

J was first released in 1990 as a successor to APL, an alternative
mathematical notation that is computer-executable and works well with
multi-dimensional array data. Most notably J switches from APL's custom
symbol-set to ASCII only, calling basic builtins by a single symbol or a
symbol with appended dot or colon, and giving distinct meaning to single
symbols that usually appear in pairs like various braces and quotes
(`[]"{}` etc).

#### Comments:

```J
NB. comments the rest of the line (latin: nota bene).
```

#### Numbers:

J has many number-notations; the most important are:
```J
3                   NB. integer
3.14                NB. float
_3                  NB. negative numbers start with underscore
_                   NB. sole underscore is infinity: a number
__                  NB. negative infinity
12j34               NB. complex/img, sometimes used to supply arg-pairs
16bcoffee           NB. base-16 number
```

#### Lists, Booleans:

Simply put elements next to each other:
```J
0 1                 NB. the booleans (FALSE, TRUE) in a two-element list
0 1 2 3             NB. list with 4 elements
(0 1) (2 3)         NB. error: can't implicitly join lists
```

#### Strings:

```J
'i''m a string: always single-quoted, only '' is special'
```

Strings are lists of characters:
```J
''                  NB. empty string is empty list
```

#### Nouns:

*Nouns* are data values and basically what was covered until now.
*Gerunds*, *arrays* and *boxes* are also nouns but they are more like
details to what was already covered. Classes and their instances are not
nouns: you cannot reference them directly. Functions aren't nouns
either.

#### Functions:

**Verbs** are functions that take nouns as their argument/s and return
nouns. A verb has access to its left argument via the local variable `x`
and to its right argument via the local variable `y`. If there are
arguments on both sides of a function it is called dyadic (such verbs
are *dyads*) otherwise the function is monadic (and such verbs are
called *monads*; not related to the haskell term).
```J
-                   NB. fn (here minus) without arg does not execute
- 1                 NB. monad (1 arg, but may be list)
1 -                 NB. error: monads take their arg from the right only
1 - 2               NB. dyad (2 args, may be lists)

- 1 2               NB. monad with list argument
0 1 , 2 3           NB. the dyad , joins lists
```
Note that the monadic and dyadic case here are two distinct functions:
negate and subtract. They share a name (the symbol `-`) and a
definition: the function `-` is *ambivalent*. A function does not have
to have both cases.

**Modifiers** are functions used to pre-process a statement/expression;
this means they run before the main evaluation step. Modifiers return a
new function that has, additionally to its own arguments `x` and `y`,
access to the original arguments as variables `u` (left, `m` may be used
instead to indicate a noun) and `v` (right, use `n` instead to indicate
a noun). The new function may return any entity, even more modifiers,
which would also be processed before the first verb evaluates!

```J
1 + 2 + 3           NB. dyadic + is addition
+  1 2 3j4          NB. monadic + gives the complex conjugates: 1 2 3j_4
+/ 1 2 3            NB. 6 because: 1 + 2 + 3 is 6
```

The last example showed that `+/x` is not the same as `+x` but rather
`x1 + x2 + x3 ...`. This is because `/` is an *adverb* (a modifier that
takes one argument to the *left*): It creates a new function that
inserts the original argument `+` between all elements of its own
argument `1 2 3`.

*Conjunctions* only differ insofar as they (meaning the original
modifier not the returned entities) take two arguments. The `:`
conjunction is commonly used to define new entities:

#### Defining entities (functions, nouns) by Explicit-Definition:

Explicit-definitions are created with the `:` conjunction that returns
an entity of the type indicated by the integer to its left:

- `0` for nouns,
- `1` for adverbs,
- `2` for conjunctions,
- `3` for monadic (optionally ambivalent) verbs,
- `4` for dyads.

The entities value is specified as the right argument and is a string
for functions. A value of `0` always means to read in the following
lines as a string - until the next line containing `)` as its only
printable character.

```J
NB. nouns
0 : 'string'            NB. creates noun with value 'string'
1 + 0 : 100             NB. creates and uses noun 100 (the number)
echo '>', (0 : 0), '<'  NB. creates noun from next lines and uses it
A Multiline string.
Make sure to put a space between the left arg and : because otherwise it
is parsed as one of the functions __: or _9: to 0: or 1: to 9: or _:
that ignore their args and always return their (negative) digit/infinity
)

NB. verbs
1 (4 : 'x + y') 2       NB. creates and uses a dyad
neg =: 3 : '-y'         NB. =: assigns (here a monad) to global name
fn =: 3 : 0             NB. creates an (ambivalent) multiline verb
  echo 'First the body of a monad, then optionally the body of a dyad'
  echo 'separated by a line containing : as its only printable symbol'
  :
  (3 :'multiline explicit-defs cannot be nested but may contain') 0
  echo 'one-line explicit-defs or (multiline) DDs (see below)'
)
fn 1
1 fn 2

NB. adverb representing number in percents
echo 0.01 (1 : '(": u * 100), ''%'' ')
percent =: 1 : 0        NB. same as multiline definition
  (": m * 100), '%'     NB. using m to indicate left arg is noun
)
echo 0.7 percent

NB. conjunction that swaps its arguments and the args of its result
swap =: 2 : 'y v u x'
1 + - 2
2 - + 1
1 + swap - 2
```

#### Index functions, helpers:

As demonstrated, explicit definitions specify the type to create as a
number. This pattern of selecting functionality with a numeric index is
sort of J's guilty pleasure. In most cases you'd look the functions up
in the docs and assign an alias to often used ones; in fact, J already
comes with a set of aliases (and other helpers). List them with
`names_z_''`. New users should definitely look over the docs for `!:`
and `o.` for once.

#### Direct definitions:

Direct definitions, *DD*s for short, are another way to write explicit
definitions. They are wrapped in double-braces and assume their type
from the argument-variable-names used:

- If variables `v` or `n` are used a conjunction,
- otherwise if `u` or `m` are used an adverb,
- otherwise if `x` is used a dyad or ambivalent verb is created.

A type may also be forced by appending `)` and one of the letters
`n`oun, `a`dverb, `c`onjunction, `m`onad or `d`yad.
```J
echo {{)nhello world}}, '!'

{{('hey, ', y, '!') return.}} 'you'

1 {{x + y}} 2

{{

    echo 'multiline DDs may contain other multiline DDs. For example:'
echo '>', {{)n  NB. this comment on an opening line of a DD is an error!
Multiline string defining DDs differ from others in that they may start
on the opening line and have to put the ending braces as the first
characters of a line (no whitespace prefix allowed).
}}, '<'             NB. expression may continue here

    :
    echo 'Apart from that DD-bodies are much like explicit definitions.'

}} 'call as monad'
```

#### (Explicit) Control-Structures and Control-Words:

J has all common control-structures and -words, however, they can only
be used within explicit functions (explicit definitions or DDs). They
are not idiomatic J and hinder new users from learning to think in array
programming style. Nevertheless, some problems are simpler to solve this
way.

- Assert: *All* elements have to be `1`.
  ```J
  assert. 1 1 1         NB. ERROR if ANY element is not 1
  assert. 1 0 1
  ```
- Conditionals: *First atom* must not be false (`0`).
  ```J
  if. 0 1 1 do.         NB. only considers FIRST atom
    echo 'if-block'
  elseif. 0 1 1 do.     NB. only considers FIRST atom
    echo 'elseif-block'
  else.
    echo 'else-block'
  end.
  ```
- Select
  ```J
  matchthis =: {{       NB. global assignment
    select. y
    case. 'a' do.
      echo '"a"'
      echo 'afterwards always jumps to end.'

    fcase. 'b' do.
      echo 'afterwards unconditionally executes next (f)case. block!'
    fcase. 'c' do.      NB. adds another valid case for the next body
    case. 'd' do.
      echo '"b", "c" or "d"'

    case. 1 2 3 do.     NB. this is one value (the list) not 1 or 2 or 3
      echo 'the list 1 2 3'

    case. do.
      echo 'empty case always matches'

    end.
  }}
  matchthis 'a'
  matchthis 'b'
  matchthis 1 2 3
  matchthis 1 2 4
  ```
- Goto: Considered Harmful - Edsger Dijkstra
- While loops: Only run if *first atom* is not false (0).
  ```J
  while. 'aa'='ab' do.  NB. only considers FIRST atom
    echo 'dyad = compares per element; here the first letters match'
    break.              NB. end loop immediately
    echo 'never echoed'
  end.
  ```
- Whilst loops: While loop that always *runs at least once*.
  ```J
  whilst. 0 do.         NB. only considers FIRST atom
    echo 'runs at least once'
    echo 'only runs once because loop condition is false'
    continue.           NB. immediately stop this & start next iteration
    echo 'never echoed'
  end.
  ```
- For (each) loops: There are no classic for loops. Iterating over a
  list of integers can mimic one.
  ```J
  items =. 100 200

  for. items do.
    echo 'runs once for each item; the current item is not available!'
    break.
  end.

  NB. the syntax is to make the variable name part of the controlword:
  for_myname. items do.
    echo 'variable myname', ": myname
    echo 'variable myname_index', ": myname_index
    continue.
  end.
  ```
- Return statements: Exit function early. Pass a return-value as *left*
  argument!
  ```J
  '"return." returns last computed noun or its left arg' return.
  ```

- Throw, Catch: TODO

#### Arrays:

**An array is a ((list of) list/s of) value/s.** Thus even single values
(scalars/atoms) are actually arrays ("0 lists of 1 element"). All
elements must have the same type, and on the same nesting-level every
element has to have the same length.

Therefore an array can be described by its type and shape, which is the
list of the lengths of elements on each nesting-level (dimension/axis).
The length of the shape is called rank.

```J
$ 0                 NB. monad $ gives shape; scalars have an empty shape
# $ 0               NB. and therefore rank 0; monad # gives arg's length
$ 0 1 2             NB. shape
# $ 0 1 2           NB. rank
2 1 $ 10 20         NB. dyad $ reshapes array; new: 2 lists of 1 element
$ 2 1 $ 10 20       NB. shape
2 $ 10 20 30        NB. reshaping may drop elements
5 $ 100 200         NB. or repeat the elements as needed
'ten', 20           NB. error: incompatible types
10, 3.14            NB. ok: both are numbers
2 2 $ 'abc'         NB. don't forget that strings are arrays too!
```

#### Boxes:

To get around the restrictions of arrays, values can be boxed: The
box pretends to be a scalar and hides its contents, which need to be
unboxed before working with them.
```J
<3                  NB. monad < puts its arg in a box
><3                 NB. monad > opens/unboxes the outer box of a value
<''                 NB. an empty box is just a boxed empty array
a:                  NB. equivalent; called "ace", a noun
1 ; 3               NB. dyad ; joins args as boxes
1 ; <3              NB. it removes 1 boxing level from its right arg
(<1); <3            NB. but not from its left arg
1 2 , 'abc'         NB. error: different types and lengths
1 2 ; 'abc'         NB. ok because ; boxes the values first
(<1 2) , <'abc'     NB. here we manually boxed the values first -> ok
```

The boxing state is the third of the three descriptive properties of a
value: type, shape, boxed?.

#### Rank:

**Rank (singular) of nouns** was already covered above. **Functions have
ranks (plural)** too: they determine on which dimension/axis
(nesting-level) of their arguments they operate and can be changed to be
able to apply a function to any array.

The three ranks (monad, dyad left, dyad right) can be shown with the
adverb `b.0`. The "rank conjunction" `"` assigns new ranks. Rank 0
works on atoms, rank infinity on the highest dimension; a negative rank
works on n dimensions lower than the rank of the argument.
```J
< b.0               NB. the default ranks of < are (_ 0 0)
<"(_) b.0           NB. "_ assigns infinity to all ranks: (_ _ _)
<"(2 1) b.0         NB. 1st to left 2nd to monadic & right rank: (1 2 1)
<"(0 1 2) b.0       NB. to respective rank: (0 1 2)

i. 2 3 4            NB. generates an integer sequence in the given shape
<"_ i. 2 3 4        NB. on the whole (_) array do box
< i. 2 3 4          NB. same because the default monadic rank of < is _
<"0 i.2 3 4         NB. on atoms (dimension/axis 0) do box (<)
<"1 i.2 3 4         NB. on lists (dimension/axis 1) do box (<)
<"2 i.2 3 4         NB. on tables (dimension/axis 2) do box (<)
<"_1 i.2 3 4        NB. same because noun rank is 3 and _1 means axis 2
<"_1 i.1 2 3 4      NB. looks the same but is rank 4 so _1 means axis 3
```

The result also depends on the verb! For example sum is "insert plus",
thus it adds the elements one dimension lower than the argument's rank:
```J
+/"1 i. 2 2         NB. sum of rows (plus between row-elements=atom)
+/"2 i. 2 2         NB. column-sum (plus between table-elements=rows)
```

When using a dyad it combines the selected parts of the left argument
with the selected parts of the right argument. Only the same shape (of
the selection made by the rank) or a scalar work!
```J
-b.0                NB. function - always works on atoms by default
4 5 6 - 1 2 3       NB. x-atoms and y-atoms combined with dyad -
4 5 6 - 1           NB. a scalar is reused for every element...
3 4 5 6 - 1 2       NB. error; every other shape is incompatible
```

Explicitly defined verbs are assumed to be of ranks `_ _ _`.
```J
fn =: 3 : 'echo y'  NB. an explicit verb
fn 1 2 3
fn=: 3 :'echo y' "0 NB. assigns ranks (0 0 0) to the explicit verb
fn 1 2 3
```

#### Frames:

A frame is the shape in which to assemble some values, for example after
iterating over and deriving values from those iterated elements.

As already discussed, a verb's rank selects rank-amount of dimensions
from (the back of) the shape to operate on. The frame of the result is
the leading dimensions that weren't selected. To get the final shape
append the verb's result's shape to the frame. If there are multiple
frames (for example with dyads) they have to agree, meaning the shorter
one has to *be the start of the longer one*; the result uses the longer
one.

```J
empty =: 3 : '1'    NB. always returns 1 (a scalars thus empty shape)
two =: 3 : '1 2'    NB. always returns list 1 2 (shape 2)
```
The following examples use the above verb definitions.
```
                            arg-shape       verb-result-    final
verb-rank                   frame, selected shape           shape
---------   EXAMPLES:       ===== ------    ============    ----
"_          empty   i.3      '' | 3         ''              ''
"0          empty"0 i.3       3 | ''        ''              3
"_          two  "_ i.3      '' | 3         2               2
"0          two  "0 i.3       3 | ''        2               3 2
"1          two"1 i.2 3       2 | 3         2               2 2
```

```J
] x234 =: 2 3 4 $ 3
] x23 =: 2 3 $ 1 1 1 2 2 2
x234 +"0 0 x23
```

Replace the rank-conjunction in the last example with the ones from the
following table:
```
            left-arg-shape  right-arg-shape verb-results-   final
verb-ranks  frame, selected frame, selected shape           shape
----------  =====  ------   ====  ------    ============    --------
"0 0        2 3 4 | ''      2 3 | ''        ''              2 3 4
"1 0          2 3 | 4       2 3 | ''        4               2 3 4
"0 1        2 3 4 | ''        2 | 3         3               2 3 4 3
"1 1          2 3 | 4         2 | 3         error: incompatible args
"2 0            2 | 3 4     2 3 | ''        3 4             2 3 3 4
"2 1            2 | 3 4       2 | 3         3 4             2 3 4
"_ _           '' | 2 3 4    '' | 2 3       2 3 4           2 3 4

The following examples use different nouns; just note the shapes:
"0 0        2 3 4 | ''    1 3 4 | ''        error: incompatibe frames
"_ _           '' | 2 3 4    '' | 1 3 4     error: incompatibe args
```

#### Padding:

Incompatible values can still be put into the same structure by using boxes.
When they are of the same type, lower dimensional values can also be
padded to match the highest dimensional value making the shapes
compatible and thus the boxes can be omitted. This is different from
reshaping! 

When unboxing values are padded automatically. Behind the scenes this
happens all the time when assembling subresults into a frame.

```J
 1; 2 2
>1; 2 2             NB. numeric arrays are padded with zeros
2 3 $ 'a'           NB. reshaping reuses the original as needed
>'a'; 'aaa'         NB. padding adds filler if necessary. here spaces
NB. note the resulting pattern:
 (2 1 $ 1); (2 3 $ 2)
>(2 1 $ 1); (2 3 $ 2)
 (2 3 $ 1); (2 3 4 $ 2)
>(2 3 $ 1); (2 3 4 $ 2)
NB. different length results are padded before being put into a frame:
(3 : '1+i.y,y' "0) 1 2 3
```

#### Evaluation:

The examples should already have given most of these rules away:

- Evaluation works right to left! A reader should do the same.
  ```J
  3 - 2 - 1         NB. 2
  +/ 3 2 1          NB. don't read this as 3 + 2 + 1 but 1 + 2 + 3
  -/ 3 2 1          NB. 2; when (x f y) is not (y f x) it's obvious
  - +/ 3 2 1        NB. result of +/ becomes right arg of -
  - 1 2 3 + 4 5 6   NB. + takes the array to its left as left arg
  0 1 + - 2 3       NB. this is (0 1 + (- 2 3))
  ```
- Parentheses form subexpressions, that finish before the parent.
  ```J
  (3-2) - 1         NB. 0
  0 1 (+) 2 3       NB. the subexpression gets arguments (0 1) and (2 3)
  0 1 (+ -) 2 3     NB. same here but this is a train (see: below)!
  ```
- No mathematical operator precedence, just right to left evaluation and
  parentheses.
  ```J
  2 * 3 + 4         NB. 14
  (2 * 3) + 4       NB. 10
  ```
- First all modifiers are evaluated until only nouns and verbs are left.
  ```J
  -/ 1 2 3          NB. modifier first replaces args with fn that does:
  1 - 2 - 3         NB. 2; no more modifiers found -> verbs evaluate
  ```
- Note that even after processing all modifiers the statement/expression
  might still not simply run right to left when there is a subexpression
  that forms a train (see below).
- Consecutive modifiers are processed left to right:
  ```J
  1 - ~ 3           NB. adverb ~ swaps the args of the verb it creates
  -~ 3              NB. or copies the right arg to the left

  -/ 1 2            NB. (1 - 2) = _1
  -~/1 2            NB. (1 -~ 2) = (2 - 1) = 1
  NB. 1. creates this verb ^^
  NB. 2. creates this   ^^^^^^^^ by inserting the (new) verb
  NB. 3. result evaluates like this^^^^^^^
  ```

#### Trains:

```
      x? (E? D    C  B  A) y
result <---- D <---- B         }combinators: dyads
            ?       / \             except when their left arg is [:
           ?       /   \
          E       C     A      }operators: use train's arg/s, monads
         ? \     ? \   ? \          except when train not hook and has x
        x?  y   x?  y x?  y
        -------------
       =======       \
    last left arg      All except the first operator may be replaced by:
 is missing in hooks        *) [: which makes the combinator a monad
then replaced with x/y      *) noun to be used as left arg of combinator
```

An isolated sequence of verbs (in other words: multiple verbs not
followed by a noun) creates a train, that is a special pattern defining
which verbs receive what arguments and execute in which order. The basic
idea is the fork, best explained by the computation of the mean:
```J
Y =: 1 2 3 4
(+/ % #) Y          NB. the mean of a list is sum divided by length
(+/ Y) % (# Y)      NB. equivalent expanded form
```

A longer train simply continues this pattern using the result of the
previous fork as the right argument to the next fork. When the last fork
doesn't get a left argument (because the train is of even length) it
uses an argument of the train instead: the left, or if missing the right
one. This is called hook-rule and when it's used the whole train is
called *a* hook, otherwise its *a* fork.
```
Train:              Expands to:                     Note:
  (    C B A) y     =            (  C y) B (  A y)  the basic fork
  (E D C B A) y     = (  E y) D ((  C y) B (  A y)) just more forks
  (  D C B A) y     =       y D ((  C y) B (  A y)) last uses hook rule
  (      B A) y     =                  y B (  A y) first is last -> hook
```

Using my own terminology, a train consists of operators (the odd
numbered verbs counting from right) that operate on the train's
arguments, and combinators (the even numbered verbs counting from right)
that are dyads combining the result of everything to their right with
the result of the operator to their left.

As said before, a hook's last combinator uses an argument of the train
to replace its missing left operator. When the train is dyadic, another
peculiarity of hooks becomes evident: A hook's operators always stay
monads:
```
x (E D C B A) y     = (x E y) D ((x C y) B (x A y)) operators -> dyads
x (  D C B A) y     =       x D ((  C y) B (  A y)) operators all monads
x (      B A) y     =                  x B (  A y) first is last -> hook
```

Any left operators may be replaced with a noun to create a so called NVV
(noun-verb-verb) fork, that simply uses this noun as its left argument:
```
x (E D 1 B A) y     = (x E y) D (      1 B (x A y))   left arg to B is 1
x (  D 1 B A) y     =       x D (      1 B (  A y))   left arg to B is 1
```

Any left operators may be replaced with `[:` to create a so called
capped fork that converts its combinator into a monad:
```
x (E D [: B A) y    = (x E y) D (        B (x A y)) fork ([:BA) -> monad
x (  D [: B A) y    =       x D (        B (  A y)) fork ([:BA) -> monad
```

#### Gerunds:

Gerunds are a special kind of array containing functions, thus create
a noun from a function:
```J
+ , -                   NB. error cannot join two functions
+ ; -                   NB. error cannot box-join two functions
+ ` -                   NB. ok: ` creates a boxed list of functions
- ` ''                  NB. gerund with only 1 element

(-`-) `:0 (_1 0 1)      NB. m`:0 applies each verb in m separately
(-_1 0 1) ,: (-_1 0 1)  NB. equivalent (,: creates 2-element array)

(-`-) `:3 (_1 0 1)      NB. inserts all verbs between all elements
_1 - - 0 - - 1          NB. equivalent

(-`-) `:6 (_1 0 1)      NB. creates a train
(- -) _1 0 1            NB. equivalent (see: trains)
```

#### Names, Scopes/Namespaces

Variable-names may only contain ASCII-letters (upper and lowercase),
numbers (but not as first character) and underscores (except leading,
trailing or double).

Assignments return their values, but the interpreter doesn't display
them.

```J
foo =: 1            NB. assignment's return-value not shown
[ foo =: foo + 1    NB. monads [ and ] return their arg/s unchanged
] foo =: foo + 1    NB. that's a common pattern to show assignment value
'foo bar' =: 1 2    NB. same lengths required
foo; bar
]'foo bar' =: 0 1;2 NB. removes one boxing level but returns original
foo; bar
```

Unknown variables are assumed to be verbs.
```J
foo =: 2 + unknown
unknown =: 5
foo + 3             NB. error unknown is not a verb
unknown =: 3 : '5'  NB. now it is
foo + 3             NB. thus no error here
```

Variables create subexpressions instead of simply representing their
value, imagine they expand to their parenthesized value:
```J
N =: 2              NB. N is not the number 2 but a subexpr returning 2
N + 10              NB. Here it doesn't matter, but if N wasn't the...
1 N 3               NB. ...subexpression but the number this would be ok
< - 1 2 3           NB. How about creating an alias for this action?
negated_box =: < -
negated_box 1 2 3   NB. Suddenly the result is different because this:
(< -) 1 2 3         NB. subexpression is a train and not (< - 1 2 3)
```

Each name lives in a namespace (locale) and every evaluation has a
context, that is a namespace in which it runs (and that can change per
function-call). Namespaces can inherit each other, which means when a
name is not found, it is looked up in the parent. J starts in an empty
namespace "base" that inherits from "z" where the helper-functions like
`echo` are defined. New namespaces by default inherit from "z".

Functions have their own private/local (unnamed) namespace that inherits
the current global namespace (which can be changed) as context, is
pre-populated with the relevant argument-variables (`x`, `y`, `u`, `v`,
`m`, `n`) and can be written to with `=.`; whereas `=:` always writes to
a global namespace. Control-structures do not have their own namespace.
Creating a variable in a namespace hides an inherited variable of the
same name until the local version is erased again.

Where to start looking for a name can also be explicitly stated with a
**locative**, that looks like this: `name_namespace_` or
`name__varContainingNSName`. Contrary to inheriting from other
namespaces, this temporarily sets the current global namespace to the
given namespace instead of the caller's. To avoid this use adverb `f.`
to capture the verb in the current namespace.

```J
coname ''           NB. get name of current namespace (should be 'base')
clear 'base'        NB. rm all names from namespace base
copath 'base'       NB. get ancestors of namespace base
findme =: 'here'    NB. =: writes to current global namespace
fn_z_ =: 3 : 0      NB. write to namespace z
  echo findme
)
nl ''               NB. get names (defined) in current namespace
fn ''               NB. fn is inherited (didn't show up), evaluates here
fn_z_ ''            NB. error: evaluates in z, parent to where findme is
```

Here is an example to see local/global scoping:
```J
conl ''             NB. get names of existing namespaces
cocurrent 'N'       NB. swich to namespace N (created if necessary)
  conl ''           NB. show N is now in namespace list
  clear 'N'         NB. rm all names from namespace
  A =: 0
  B =. 1            NB. =. outside of function is like =:
  C =. 2
  i =: 1000         NB. if unshadowed it will be overriden by for_i
  f =: 3 : 0
    A =: 1          NB. updates global A
    B =. 2          NB. shadows global B
    C =. 3          NB. shadows global C
    D =: 4          NB. writes to global namespace
    NB. i =. 100    NB. shadowing global i to protect it
    for_i. 1 do.    NB. will override vars of same name!
      E =. 5        NB. control-structures don't have own-, use fn-scope
    end.
    echo A;B;C;D;E;i    NB. echo is inherited from z (default parent)
    erase 'B'           NB. rm local B -> global B is visible again
    echo A;B;C;D;E;i
  )

cocurrent 'base'
f_N_ ''
A;B;C;D;E;i
A_N_ ; B_N_ ; C_N_ ; D_N_ ; E_N_ ; i_N
```

Classes in J are just namespaces; instances can be created with `conew`
and then initialized by calling the constructor. This can be done in one
step by defining a monad `create` that receives the left argument of
`conew` automatically. `conew` returns the boxed numeric-string-id of
the new instance. To access a namespace via its boxed name saved in a
variable, append two underscores and the variable to the target name.
```J
coclass 'Parent'            NB. switch namespace
  instances =: 0 $ <''      NB. empty boxed list
  create =: 3 : 0
    echo 'in'; coname''     NB. if 'Parent' you're in wrong namespace
    instances =: instances, coname''
  )
  set =: 3 : 'field =: y'
  pmeth =: 3 : 'echo field'

coclass 'Child'             NB. switch namespace
  NB. ((<'Parent'),(copath 'Child')) copath 'Child'     NB. or simply:
  coinsert 'Parent'
  copath 'Child'            NB. show ancestor list
  not_local =. '=. only works in functions'
  create =: 3 : 0           NB. constructor
    NB. using locative to avoid recursion
    NB. using f. to avoid executing in locative's namespace
    create_Parent_ f. ''
    set_Parent_ f. y        NB. prefer parent methods over direct access
    NB. field =: y          NB. ... which would look like this
  )
  destroy =: 3 : 'codestroy '''''       NB. destructor
  get =: 3 :'field return.' NB. no getter in parent -> use direct access
  inc =: 3 : 'set_Parent_ f. field + 1'

cocurrent 'base'            NB. switch namespace
o1 =: 10 conew 'Child'      NB. create instance
o2 =: 20 conew 'Child'      NB. another instance
nl__o1 ''                   NB. evaluate nl in instance's namespace
COCREATOR__o1               NB. auto-created field accessed from outside
(inc__o1 ''), inc__o2 ''    NB. invoke method, changes state of instance
(get__o1 ''); get__o2 ''    NB. show values are indeed different
field__o1 =: 101            NB. assign to a field from outside
pmeth__o1 ''                NB. inheritedMethod__child executes in child
not_local__o1               NB. =. outside of fn does not hide a field
(destroy__o1 ''),destroy__o1 ''     NB. call destructors
coerase'Child';'Parent';'N' NB. or rm namespaces by name
erase 'o1';'o2'             NB. rm now invalid references
```

#### Indexing:

How indices work in J:

- The first element has index `0`.
- Negative indices select from the back (thus the last element can be
  accessed with index `_1`).
- Each element in an index is a separate selection (of what differs per
  verb).
- An *unboxed list* of indices selects (multiple of) the array's
  top-level elements, because each element is a separate selection and
- *trailing* axes/dimensions may be omitted, resulting in all their
  elements being selected.
- Top-level boxes (**1st boxing level**) contain paths, that is lists of
  *selections per axis/dimension* of an array. In other words: Each
  element in a box selects on a different axis/dimension of the array,
  which effectively means they subindex the previous result.
- To select several elements on the same axis/dimension group them in
  another box (**2nd boxing level**).
- *Instead*, elements can be excluded per axis/dimension by wrapping
  them with another two boxes (**3rd boxing level**).
- To select all elements of an axis/dimension exclude none by putting an
  empty array at the third boxing level (`<<<''` or `<<a:`).
- Keep in mind that `;` doesn't add a boxing level to a boxed right
  argument!

The verb `{` can index arrays but not boxes. Every element in its left
argument is a new selection starting from the same dimension (that the
verb was applied to).
```J
{ b.0                   NB. show ranks of {
] a =: i. 4 4
0 { a                   NB. first
_1 { a                  NB. count from back
0 0 { a                 NB. separate selections starting at same level
(<0 0) { a              NB. top-level boxes contain paths
(1 1; 2 2) { a          NB. separate selections with paths
(1; 1 1) { a            NB. different length results need padding
(<(<0),(<1 3)) { a      NB. select multiple elements per axis in path
(<(<a:),(<<_2)) { a     NB. exclude per axis (excl none = select all)
```

`{::` is like `{` but *opens its results* and uses *each path to
continue indexing into the previous result* instead of returning to the
starting level and producing more result values. The final *result is
not opened if* it is not a single box or the *last path's last part is a
list* (monad `,` can be used to promote a scalar to rank 1). `{::` only
works with paths because it will wrap lists of numbers in a box first.
```J
]a =: 1 2 3; 4 5 6; 7 8 9
(1;1) { a               NB. paths start at same level
(1;1) {:: a             NB. paths continue indexing previous result
]a =: <<"0 i.3 3
(0;1 1) {:: a           NB. final scalar box result is opened, except:
(0;(<1;,1)) {:: a       NB. last path's last part is a list due to ,y
(0; 1) {:: a            NB. not opened because result isn't a scalar box
(0; (<(<<1))) {:: a     NB. excluding stuff etc works as it would with {
```

Back to functions that do not have access to box contents:

To replace elements use the `}` adverb that is used like `{` with an
additional left argument specifying the replacement/s:
```J
(2) 1 } 1 200 3
' ' (<(<<_1),(<1)) } 4 4 $ 'abcdefghijklmnop'
(2 2 $ '1234') (<(<1 2),(<1 2)) } 4 4 $ 'abcdefghijklmnop'

orig =: 'immediate reassigment modifies in-place (prevents copy)'
copy =: orig        NB. creates copy instead of pointing to same object
orig=: 'I' 0 }orig  NB. reassigning to same name modifies in-place BUT:
orig ,: copy        NB. 'copy' unchanged despite orig changed in-place
```

To be able to write index getters that work for any array `}` accepts a
dyadic function as left argument. This function takes the replacement
and original-array as left and right arguments (respectively) and
returns the indices *of a flattened version of the array* at which to
replace values.
```J
_ (1) } i.2 3       NB. noun-indices access the unflattened array
_ 1: } i. 2 3       NB. indices from functions are for flattened arrays

1 0 2 # 'abc'       NB. dyad # copies corresponding element in y x-times
fn =. 4 : 0
    Y =. , y        NB. monad , flattens an array
    bitmask =. Y<x  NB. where element less than replacement...
    bitmask # i. #Y NB. ...keep, else drop index from flat-indices list
)
0 fn } 2 6 $ foo =: _4 2 9 3 8 5 _7 _2 3 1 _3 2
0 fn } 2 2 3 $ foo
```

Ranges can be conveniently specified with (combinations of) the
following verbs:
```J
] digits =: i.10
    {: digits       NB. last            (no dyadic version)
    {. digits       NB. first
  3 {. digits       NB. first 3
2 1 {. 3 3 $ digits NB. first 1 of first 2
    }: digits       NB. drop last     (no dyadic version)
    }. digits       NB. drop first
  3 }. digits       NB. drop first 3
1 2 }. 3 3 $ digits NB. drop first 1 then first 2 (reshaping dropped 9)
```

#### Importing code:

The following verbs inherited from the z-locale are used to import code:

- `load`: Runs the specified file or shortname (list shortnames with
  `scripts''`).
- `loadd`: Like `load` but displays the lines before executing them.
- `require`: Like `load` but files that were already loaded won't be
  loaded again.

## Appendix

#### Covered builtins:
```
comment         NB.     comment rest of line
noun            _       infinity, but as number-prefix: negative sign
monad           -       negate
dyad            -       subtract
dyad            ,       join lists
dyad            +       addition
monad           +       complex conjugate
adverb          /       puts verb between elements of new verb's arg/s
conjunction     :       define entities, separate monad and dyad bodies
monad           echo    output message
ambivalent      __: _9: ... 0: ... 9: _: ignore arg/s and return digit
monad           ":      convert to displayable byte array
dyad            *       multiplication
monad           names   show names defined in current namespace
(conjunction    !:)     access lots of system functions
(dyad           o.)     access to circle functions (sin, cos, ...)
assignment      =:      assign to global namespace
assignment      =.      try assigning to local namespace else to global
dyad            =       compare per element
monad           $       get shape
monad           #       get length
dyad            $       reshape array
monad           <       box
monad           >       unbox/open
noun            a:      empty box
dyad            ;       join as boxes
adverb          u b. 0  show ranks of verb u
conjunction     "       set ranks of verb
monad           i.      get integer sequence in shape of argument
adverb          ~       swap arguments or copy right arg to left side
monad           [       return argument unchanged
monad           ]       return argument unchanged
dyad            %       division
ambivalent      [:      x?([: B A)y becomes (B x?Ay)
conjunction     `       make list of verbs (gerund)
conjunction     `:      execute a gerund in a certain way
dyad            ,:      combine into an array of two elements
adverb          f.      pull name into current namespace
monad           coname  get name of current namespace
monad           clear   remove all names defined in namespace
monad           copath  ancestors of namespace
monad           nl      boxed list of names defined in current namespace
monad           conl    list namespaces
monad           cocurrent   switch to namespace
monad           erase   remove given names from current namespace
monad           conew   create new instance of class
dyad            conew   create new instance and pass y as args to create
monad           coclass switch to namespace
dyad            copath  set ancestors of namespace
monad           copath  show ancestors of namespace
monad           coinsert    prepend ancestors of current namespace
monad           codestroy   remove current namespace
monad           coerase remove namespace
dyad            {       index into array
dyad            {::     index into boxed structure
monad           ,       flatten array; scalar becomes list
adverb          }       return copy of array with replaced elements
dyad            #       repeat curresponding elements x-times
monad           {:      last element
monad           {.      first element
dyad            {.      first x elements
monad           }:      except last element
monad           }.      except first element
dyad            }.      except first x elements
monad           load    executes file or shortname (alias for a file)
monad           scripts show shortnames
monad           loadd   like load but print each line before executing
monad           require like load but only if was not loaded already
```

#### Abbreviations:

- x                 ... left arg (in modifiers: of created entity)
- y                 ... right arg (in modifiers: of created entity)
- u                 ... left arg of modifier, indicates it is a verb
- v                 ... right arg of modifier, indicates it is a verb
- m                 ... left arg of modifier, indicates it is a noun
- n                 ... right arg of modifier, indicates it is a noun
- fn                ... function
- arg/s             ... argument/s
- esc               ... escape
- elem/s            ... element/s
- dim/s             ... dimension/s
- docs              ... documentation
- excl              ... excluding
