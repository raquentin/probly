import gleam/float
import gleam/io

import probly

// Model dice rolls with `probly.uniform`.
pub fn main() {
  let die =
    [1, 2, 3, 4, 5, 6]
    |> uniform

  let event_3 = fn(x) { x == 3 }
  let p_3 = probly.probability_of_event(event_3, die)
  io.println("Probability of rolling a 3: " <> float.to_string(p_3))

  let two_dice = probly.combine_dist(die, die)

  let sum_is_7 = fn(dice: #(Int, Int)) { dice.0 + dice.1 == 7 }
  let p_sum_7 = probly.probability_of_event(sum_is_7, two_dice)
  io.println("Probability sum of two dice = 7: " <> float.to_string(p_sum_7))
}
