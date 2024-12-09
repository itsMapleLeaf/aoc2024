import gleam/dict
import gleeunit/should
import lib/util

pub fn counts_test() {
  [1, 1, 1, 2, 3, 3]
  |> util.counts
  |> should.equal(dict.from_list([#(1, 3), #(2, 1), #(3, 2)]))
}

pub fn counts_empty_test() {
  []
  |> util.counts
  |> should.equal(dict.from_list([]))
}

pub fn int_sign_test() {
  util.int_sign(0) |> should.equal(0)
  util.int_sign(-5) |> should.equal(-1)
  util.int_sign(5) |> should.equal(1)
}
