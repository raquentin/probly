import gleeunit
import gleeunit/should

import gleam/float
import gleam/int
import gleam/list
import gleam/order

import probly.{type Dist}

/// Tolerance for loose float equivalances.
const float_tolerance = 0.00000001

pub fn main() {
  gleeunit.main()
}

pub fn probability_of_event_test() {
  let dist: probly.Dist(Int) = [#(1, 0.4), #(2, 0.6), #(1, 0.1)]
  let event: probly.Event(Int) = fn(value) { value == 1 }

  let result = probly.probability_of_event(event, dist)
  should.equal(result, 0.5)
}

pub fn normalize_test() {
  // "1" appears twice
  let dist: Dist(Int) = [#(1, 0.3), #(2, 0.2), #(1, 0.4)]
  let normed = probly.normalize(dist)

  let sorted = list.sort(normed, compare_int_dist)
  should.equal(sorted, [#(1, 0.7), #(2, 0.2)])
}

pub fn combine_dist_test() {
  let dist1 = [#(1, 0.4), #(2, 0.6)]
  let dist2 = [#(10, 0.2), #(20, 0.8)]

  let actual = probly.combine_dist(dist1, dist2)

  let expected = [
    #(#(1, 10), 0.08),
    #(#(1, 20), 0.32),
    #(#(2, 10), 0.12),
    #(#(2, 20), 0.48),
  ]

  let sorted_actual = list.sort(actual, compare_int_pairs)
  let sorted_expected = list.sort(expected, compare_int_pairs)

  should.equal(list.length(sorted_actual), list.length(sorted_expected))

  let pairs = list.zip(sorted_actual, sorted_expected)

  list.fold(
    pairs,
    0,
    fn(acc: Int, pairs: #(#(#(Int, Int), Float), #(#(Int, Int), Float))) {
      let #(actual, exp) = pairs
      let #(#(ax1, ax2), a_prob) = actual
      let #(#(ex1, ex2), e_prob) = exp

      should.equal(#(ax1, ax2), #(ex1, ex2))

      should.be_true(float.loosely_equals(
        a_prob,
        with: e_prob,
        tolerating: float_tolerance,
      ))

      acc
    },
  )
}

pub fn combine_dist_normalized_test() {
  let dist1 = [#(1, 0.4), #(1, 0.1)]
  let dist2 = [#(10, 0.5), #(10, 0.3), #(20, 0.2)]

  let actual = probly.combine_dist_normalized(dist1, dist2)
  let expected = [#(#(1, 10), 0.4), #(#(1, 20), 0.1)]

  let sorted_actual = list.sort(actual, compare_int_pairs_dist)
  let sorted_expected = list.sort(expected, compare_int_pairs_dist)

  should.equal(list.length(sorted_actual), list.length(sorted_expected))

  let pairs = list.zip(sorted_actual, sorted_expected)
  list.fold(
    pairs,
    0,
    fn(acc: Int, pair: #(#(#(Int, Int), Float), #(#(Int, Int), Float))) {
      let #(#(ax1, ax2), a_prob) = pair.0
      let #(#(ex1, ex2), e_prob) = pair.1

      should.equal(#(ax1, ax2), #(ex1, ex2))

      should.be_true(float.loosely_equals(
        a_prob,
        with: e_prob,
        tolerating: float_tolerance,
      ))

      acc
    },
  )
}

fn compare_int_pairs(
  a: #(#(Int, Int), Float),
  b: #(#(Int, Int), Float),
) -> order.Order {
  let #(#(a1, a2), _) = a
  let #(#(b1, b2), _) = b
  case a1 < b1 {
    True -> order.Lt
    False ->
      case a1 > b1 {
        True -> order.Gt
        False ->
          case a2 < b2 {
            True -> order.Lt
            False ->
              case a2 > b2 {
                True -> order.Gt
                False -> order.Eq
              }
          }
      }
  }
}

/// Compare #((Int, Int), Float) by the (Int, Int) portion
fn compare_int_pairs_dist(
  a: #(#(Int, Int), Float),
  b: #(#(Int, Int), Float),
) -> order.Order {
  let #(#(a1, a2), _) = a
  let #(#(b1, b2), _) = b
  case a1 < b1 {
    True -> order.Lt
    False ->
      case a1 > b1 {
        True -> order.Gt
        False -> {
          // a1 == b1, compare a2 vs b2
          case a2 < b2 {
            True -> order.Lt
            False ->
              case a2 > b2 {
                True -> order.Gt
                False -> order.Eq
              }
          }
        }
      }
  }
}

/// Compare #(Int, Prob) by the Int value, ascending.
fn compare_int_dist(
  a: #(Int, probly.Prob),
  b: #(Int, probly.Prob),
) -> order.Order {
  let #(val_a, _prob_a) = a
  let #(val_b, _prob_b) = b
  int.compare(val_a, val_b)
}
