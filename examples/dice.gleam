import gleam/float
import gleam/io

import probly

// Define a distribution for a fair coin
pub fn main() {
  // A fair 6-sided die
  let die =
    [1, 2, 3, 4, 5, 6]
    |> uniform

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
