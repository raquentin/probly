import gleam/float
import gleam/io

import probly

// Model coin flips with `probly.bernoulli`.
pub fn main() {
  let coin = bernoulli(0.5)
  let is_heads = fn(x) { x == True }

  let p_heads = probability_of_event(is_heads, coin)
  io.println("Probability of heads: " <> float.to_string(p_heads))

  let two_coins = combine_dist(coin, coin)
  let both_heads_event = fn(e: #(Bool, Bool)) { e.0 == True && e.1 == True }

  let p_both_heads = probability_of_event(both_heads_event, two_coins)
  io.println("Probability both heads: " <> float.to_string(p_both_heads))
}
