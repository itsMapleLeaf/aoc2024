import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder
import simplifile
import util

pub fn part1() {
  let result = reports() |> list.count(is_safe)
  io.println("Day 2 Part 1: " <> string.inspect(result))
}

pub fn part2() {
  let result = reports() |> list.count(is_mostly_safe)
  io.println("Day 2 Part 2: " <> string.inspect(result))
}

fn reports() {
  let assert Ok(content) = simplifile.read("src/day2.txt")

  // let content =
  //   "7 6 4 2 1
  // 1 2 7 8 9
  // 9 7 6 2 1
  // 1 3 2 4 5
  // 8 6 4 4 1
  // 1 3 6 7 9"

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
