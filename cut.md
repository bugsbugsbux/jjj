# Conjunction `;.` with a right argument becomes an adverb:

## monadic adverb `;.0` (rank _)

Apply verb to `y` with all axes reversed.
```J
[    i.2 3 4
[;.0 i.2 3 4        NB. reverses dimensions -> result shape unchanged
|: i.2 3 4          NB. for comparison; reverses shape -> shape changes
```

## dyadic adverb `;.0` (ranks 2 _)

Apply verb to window at position and shape `x`. `x` is table with first
line giving starting positions per axis, and second line giving number
of elements to take. Thus `x` can be created `pos ,: shape`.
```J
(1 2 ,: 3 4) ];.0 i.10 10
```

## monadic adverbs `;.1`, `;._1`, `;.2` and `;._2` (all rank _)

These adverbs apply their verb to each part of y which is delimited by
occurrences of a certain element of `y`. The variants with 1 start each
part with the first element of `y`, while the variants with 2 end each
part with the last element of `y`. The negative variants remove the
delimiting element before applying the verb.
```J
< ;.1  '-ab-=cd='
< ;.2  '-ab-=cd='
< ;._1 '-ab-=cd='
< ;._2 '-ab-=cd='
```

## dyadic adverbs `;.1`, `;._1`, `;.2` and `;._2` (all rank 1 _)

These adverbs are similar to their monadic variants but instead of using
every occurrence of the first/last item as delimiter, the positions of
the delimiters are given explicitly by boolean list `x`. To select per
axis/dimension supply a boolean list for each as list of boxes; an empty
element takes the whole dimension.
```J
0 1 0 1 0 <;.1  'a-b-a' NB. everything before first delimiter is missing
0 1 0 1 0 <;.2  'a-b-a' NB. everything after last delimiter is missing
0 1 0 1 0 <;._1 'a-b-a' NB. without demiliter
0 1 0 1 0 <;._2 'a-b-a' NB. without delimiter

0 1 0 0 0 <;.1  'a-b-a' NB. x is delimiters not this elem's occurrences

NB. per line put delimiters on first and second elements
(''; ''; 1 1 0 0 0) <;.1 i.3 4 5
NB. + per table put delimiters on second and third line
(''; 0 1 1 0; 1 1 0 0 0) <;.1 i.3 4 5
NB. + per brick put delimiters on second table
(0 1 0; 0 1 1 0; 1 1 0 0 0) <;.1 i.3 4 5
```

## dyadic adverbs `;.3` and `;._3` (ranks 2 _)

These create a moving window and apply their verb to its contents. The
difference is that the negative variant stops moving the window in a
direction if there are no more elements, while the positive variant
keeps moving the window in a direction as long as it can see something.
Therefore what the window of a negative variant sees always has the same
shape.

The first line in `x` specifies the movement of the window, but can be
omitted, in which case the window moves by 1. (The second line in) `x`
specifies how many elements to take per axis/dimension, which can also
be thought of as the shape of the window for low dimensional data.

```J
i.5 5
2 3 <;._3 i.5 5             NB. x of rank 1 interpreted as (1,:x)
2 3 <;.3  i.5 5

i.3 4 5
  2 3 <;._3 i.3 4 5         NB. unexpected result as it means: (2 3 _)
1 2 3 <;._3 i.3 4 5         NB. while this window shape was intended

(1 2,:2 3) <;.3  i.5 5      NB. move by 2 on lines and by 1 on tables
(2 1,:2 3) <;.3  i.5 5
(2 2,:2 3) <;.3  i.5 5

NB. non-overlapping views by setting movement to window's shape
(,:~ 2 3)  <;.3  i.5 5
(,:~ 2 3)  <;._3 i.5 5
```

## monadic adverbs `;.3` and `;._3` (rank _)

These are same as the dyadic versions but automatically compute the
shape of the window: Each dimension is as long as the shortest dimension
of `y` and the rank is the same as `y`.
```J
<;._3 i.2 3           NB. 2 (lowest in shape of y) 2x (rank of y): (2 2)
<;._3 i.2 3 4         NB. 3#2 gives a shape of (2 2 2)
$;.3  i.2 3 4         NB. note: *rank* doesnt change; but shape does
```
