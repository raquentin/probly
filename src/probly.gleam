import gleam/list
import gleam/pair

pub type Prob =
  Float

pub type Dist(a) =
  List(#(a, Prob))

pub type Spread(a) =
  fn(List(a)) -> Dist(a)

pub type Event(a) =
  fn(a) -> Bool

pub fn probability_of_event(event: Event(a), dist: Dist(a)) -> Prob {
  dist
  |> list.filter(fn(e) { event(e.0) })
  |> list.map(fn(e) { e.1 })
  |> sum
}

fn sum(xs: List(Prob)) -> Prob {
  list.fold(xs, 0.0, fn(x, acc) { x +. acc })
}

/// Combine distributions assuming independence.
/// For every (value1, prob1) in dist1 and (value2, prob2) in dist2,
/// produce ((value1, value2), prob1 * prob2).
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
pub fn normalize(dist: Dist(a)) -> Dist(a) {
  // Fold over the original distribution, accumulating a "normalized" list
  list.fold(dist, [], fn(acc: Dist(a), element: #(a, Prob)) {
    insert_or_update(element, acc)
  })
}

/// Insert or update `(val, prob)` in the given accumulator list.
/// If `val` already exists, add `prob` to it. Otherwise, prepend `(val, prob)`.
fn insert_or_update(element: #(a, Prob), acc: Dist(a)) -> Dist(a) {
  let val = pair.first(element)
  let prob = pair.second(element)
  case acc {
    [] ->
      // Nothing in the accumulator yet; just put this element in
      [#(val, prob)]

    [#(existing_val, existing_prob), ..tail] ->
      case existing_val == val {
        True -> [#(existing_val, existing_prob +. prob), ..tail]
        False -> [
          #(existing_val, existing_prob),
          ..insert_or_update(element, tail)
        ]
      }
  }
}

pub fn combine_dist_normalized(dist1: Dist(a), dist2: Dist(b)) -> Dist(#(a, b)) {
  combine_dist(dist1, dist2)
  |> normalize
}
