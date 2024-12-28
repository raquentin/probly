import gleeunit/should

import probly/random

pub fn uniform_test() {
  let value = random.uniform()
  should.be_true(value >=. 0.0 && value <=. 1.0)
}
