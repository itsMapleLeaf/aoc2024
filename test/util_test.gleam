import gleam/dict
import gleeunit/should
import util

pub fn util_counts_test() {
  [1, 1, 1, 2, 3, 3]
  |> util.counts
  |> should.equal(dict.from_list([#(1, 3), #(2, 1), #(3, 2)]))
}

pub fn util_counts_empty_test() {
  []
  |> util.counts
  |> should.equal(dict.from_list([]))
}
