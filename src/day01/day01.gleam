import gleam/dict
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import lib/solution.{Solution}
import lib/util

pub fn solution() {
  Solution(
    day: 1,
    example: "3   4
4   3
2   5
1   3
3   9
3   3",
    part1: fn(input) {
      let input = parse_location_id_lists(input)
      list.map2(
        list.sort(input.0, by: int.compare),
        list.sort(input.1, by: int.compare),
        int.subtract,
      )
      |> list.map(int.absolute_value)
      |> int.sum
    },
    part2: fn(input) {
      let input = parse_location_id_lists(input)
      let counts = util.counts(input.1)
      input.0
      |> list.map(fn(id) {
        let count = counts |> dict.get(id) |> result.unwrap(0)
        id * count
      })
      |> int.sum
    },
  )
}

fn parse_location_id_lists(content: String) {
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
