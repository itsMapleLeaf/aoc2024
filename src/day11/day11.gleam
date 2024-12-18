import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder
import gleam_community/maths/elementary
import lib/solution.{Solution}
import lib/util

const example_input = "125 17"

// const example_input = "0 1 10 99 999"

pub fn solution() {
  Solution(day: 11, example: example_input, part1:, part2:)
}

fn parse_stones(input) {
  input
  |> string.split(" ")
  |> list.map(util.assert_parse_int)
}

fn part1(input: String) {
  parse_stones(input) |> blink_stones(25)
}

fn part2(input: String) {
  parse_stones(input) |> blink_stones(75)
}

fn blink_stones(values: List(Int), times: Int) {
  counts(values)
  |> yielder.iterate(fn(stone_counts) {
    let stone_entries = dict.to_list(stone_counts)

    let new_stone_expansions =
      list.map(stone_entries, fn(entry) {
        let #(stone, multiplier) = entry
        let expanded_entry_stones = step(stone)
        #(expanded_entry_stones, multiplier)
      })

    let new_stone_counts =
      list.fold(new_stone_expansions, dict.new(), fn(new_stone_counts, entry) {
        let #(entry_stones, multiplier) = entry
        list.fold(entry_stones, new_stone_counts, fn(new_stone_counts, stone) {
          dict.upsert(new_stone_counts, stone, fn(count) {
            option.unwrap(count, 0) + multiplier
          })
        })
      })

    new_stone_counts
  })
  |> yielder.at(times)
  |> util.assert_ok
  |> dict.values
  |> int.sum
}

fn counts(of items: List(a)) -> dict.Dict(a, Int) {
  items
  |> list.fold(dict.new(), fn(counts, value) {
    counts
    |> dict.upsert(value, fn(count) { option.unwrap(count, 0) + 1 })
  })
}

fn step(value: Int) {
  case value, digit_count(value) {
    0, _ -> [1]
    _, Ok(digit_count) if digit_count % 2 == 0 -> {
      let #(left, right) = split_int(value, digit_count / 2)
      [left, right]
    }
    _, _ -> [value * 2024]
  }
}

fn digit_count(num: Int) {
  use log10 <- result.try(elementary.logarithm_10(int.to_float(num)))
  Ok(float.truncate(log10) + 1)
}

fn split_int(num: Int, digits: Int) {
  let tens_multiplier =
    int.power(10, int.to_float(digits))
    |> util.assert_ok
    |> float.truncate

  let right = num % tens_multiplier
  let left = num / tens_multiplier

  #(left, right)
}
