import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile
import util

pub fn part1() {
  let #(first, second) = location_id_lists()

  let result =
    list.map2(
      list.sort(first, by: int.compare),
      list.sort(second, by: int.compare),
      int.subtract,
    )
    |> list.map(int.absolute_value)
    |> int.sum

  io.println("Day 1 Part 1: " <> string.inspect(result))
}

pub fn part2() {
  let #(first, second) = location_id_lists()
  let counts = util.counts(second)

  let result =
    first
    |> list.map(fn(id) {
      let count = counts |> dict.get(id) |> result.unwrap(0)
      id * count
    })
    |> int.sum

  io.println("Day 1 Part 2: " <> string.inspect(result))
}

fn location_id_lists() {
  let assert Ok(content) = simplifile.read("src/day1.txt")

  //   let content =
  //     "3   4
  // 4   3
  // 2   5
  // 1   3
  // 3   9
  // 3   3"

  content
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_location_id_pair)
  |> list.unzip
}

fn parse_location_id_pair(pair_string: String) {
  let assert Ok(spaces_regex) = regexp.from_string("\\s+")

  let assert [Ok(first), Ok(second)] =
    regexp.split(pair_string, with: spaces_regex)
    |> list.map(int.parse)

  #(first, second)
}
