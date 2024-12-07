import gleam/int
import gleam/list
import gleam/string
import gleam/yielder
import solution.{Solution}
import util

pub fn solution() {
  Solution(
    day: 2,
    example: "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9",
    part1: fn(input) { input |> parse_input |> list.count(is_safe) },
    part2: fn(input) { input |> parse_input |> list.count(is_mostly_safe) },
  )
}

fn parse_input(content: String) {
  content
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_report)
}

fn parse_report(input: String) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(util.assert_parse_int)
}

fn is_safe(report: List(Int)) {
  is_sorted(report) && is_gradual(report)
}

/// safe, or with a single bad level
fn is_mostly_safe(report: List(Int)) {
  is_safe(report)
  || {
    yielder.range(0, list.length(report) - 1)
    |> yielder.any(is_safe_without_level_at(report, _))
  }
}

fn is_safe_without_level_at(report: List(Int), index: Int) {
  let #(left, right) = list.split(report, index)

  // the first element of the right side is the potential error
  let right = right |> list.drop(1)

  is_safe(list.flatten([left, right]))
}

fn is_sorted(report: List(Int)) {
  let sorted = report |> list.sort(int.compare)
  report == sorted || report == list.reverse(sorted)
}

fn is_gradual(report: List(Int)) {
  report
  |> list.window_by_2
  |> list.all(fn(pair) {
    let diff = int.absolute_value(pair.0 - pair.1)
    diff >= 1 && diff <= 3
  })
}
