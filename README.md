# 🎲 probly

[![Package Version](https://img.shields.io/hexpm/v/probly)](https://hex.pm/packages/probly)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/probly/)

## Probabalistic functional programming, without typeclasses

This library is largely influenced by **Probabilistic Functional Programming in Haskell** by Martin Erwig and Steve Kollmansberger. This implementation adapts the paper's model to Gleam's simpler functional interface. See [All you need is data and functions](https://mckayla.blog/posts/all-you-need-is-data-and-functions.html).

## Usage

```sh
gleam add probly
```

```gleam
import gleam/float
import gleam/io

import probly

// Define a distribution for a fair coin
pub fn main() {
  // A fair 6-sided die
  let die = [
    #(1, 1.0 /. 6.0),
    #(2, 1.0 /. 6.0),
    #(3, 1.0 /. 6.0),
    #(4, 1.0 /. 6.0),
    #(5, 1.0 /. 6.0),
    #(6, 1.0 /. 6.0),
  ]

  // Probability that the die shows a 3
  let event_3 = fn(x) { x == 3 }
  let p_3 = probly.probability_of_event(event_3, die)
  io.println("Probability of rolling a 3: " <> float.to_string(p_3))

  // Combine two dice
  let two_dice = probly.combine_dist(die, die)

  // Probability that the sum of the two dice is 7
  let sum_is_7 = fn(dice: #(Int, Int)) { dice.0 + dice.1 == 7 }
  let p_sum_7 = probly.probability_of_event(sum_is_7, two_dice)
  io.println("Probability sum of two dice = 7: " <> float.to_string(p_sum_7))
}
```

Find more examples in `/examples/`, and further documentation at <https://hexdocs.pm/probly>.

## Resources

```
Martin Erwig and Steve Kollmansberger. 2006. FUNCTIONAL PEARLS: Probabilistic functional programming in Haskell. J. Funct. Program. 16, 1 (January 2006), 21–34. https://doi.org/10.1017/S0956796805005721
```
