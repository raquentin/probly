import gleam/float
import gleam/io

import probly

// Define a distribution for a fair coin
pub fn main() {
  let coin = [#("Heads", 0.5), #("Tails", 0.5)]

  // Define an event: "heads"
  let is_heads = fn(x) { x == "Heads" }

  // Probability of heads
  let p_heads = probly.probability_of_event(is_heads, coin)
  io.println("Probability of heads: " <> float.to_string(p_heads))

  // Combine two coin flips (independent)
  let two_coins = probly.combine_dist(coin, coin)

  // Probability that "both are heads"
  let both_heads_event = fn(e: #(String, String)) {
    e.0 == "Heads" && e.1 == "Heads"
  }

  let p_both_heads = probly.probability_of_event(both_heads_event, two_coins)
  io.println("Probability both heads: " <> float.to_string(p_both_heads))
}
