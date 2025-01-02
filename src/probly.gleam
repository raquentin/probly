import gleam/list
import gleam/pair

/// The probability of an event occuring. Within [0, 1].
pub type Prob =
  Float

/// Represents the outcome of a probabilistic event as a collection of
/// all possible values, tagged with their likelihood.
pub type Dist(a) =
  List(#(a, Prob))

/// Functions that "spread" values across distributions by assigning them
/// with probabilities. Examples include `uniform` and `binomial`.
pub type Spread(a) =
  fn(List(a)) -> Dist(a)

/// Match an entry in a Dist to a given value of type `a`.
pub type Event(a) =
  fn(a) -> Bool

/// Retrieve the probability of an Event within a Dist occuring.
pub fn probability_of_event(event: Event(a), dist: Dist(a)) -> Prob {
  dist
  |> list.filter(fn(e) { event(e.0) })
  |> list.map(fn(e) { e.1 })
  |> sum
}

/// Accumulate probabilities for events, presumably of the same `a` value.
fn sum(xs: List(Prob)) -> Prob {
  list.fold(xs, 0.0, fn(x, acc) { x +. acc })
}

/// Combine distributions, assuming independence.
pub fn combine_dist(dist1: Dist(a), dist2: Dist(b)) -> Dist(#(a, b)) {
  dist1
  |> list.flat_map(fn(e1: #(a, Prob)) {
    let val1 = pair.first(e1)
    let prob1 = pair.second(e1)

    dist2
    |> list.map(fn(e2: #(b, Prob)) {
      let val2 = pair.first(e2)
      let prob2 = pair.second(e2)
      #(#(val1, val2), prob1 *. prob2)
    })
  })
}

/// Merge duplicates in a distribution by summing probabilities.
/// "normalize" is a bit overloaded, this function does not ensure
/// that the sum of all probabilities across a Dist is 1.
pub fn normalize(dist: Dist(a)) -> Dist(a) {
  list.fold(dist, [], fn(acc: Dist(a), event: #(a, Prob)) {
    insert_or_update(event, acc)
  })
}

/// A helper to insert or update `event`s in a given `Dist`.
fn insert_or_update(event: #(a, Prob), acc: Dist(a)) -> Dist(a) {
  let val = pair.first(event)
  let prob = pair.second(event)
  case acc {
    [] -> [#(val, prob)]

    [#(existing_val, existing_prob), ..tail] ->
      case existing_val == val {
        True -> [#(existing_val, existing_prob +. prob), ..tail]
        False -> [
          #(existing_val, existing_prob),
          ..insert_or_update(event, tail)
        ]
      }
  }
}

/// Normalize the combinination two `Dist`s.
pub fn combine_dist_normalized(dist1: Dist(a), dist2: Dist(b)) -> Dist(#(a, b)) {
  combine_dist(dist1, dist2)
  |> normalize
}
