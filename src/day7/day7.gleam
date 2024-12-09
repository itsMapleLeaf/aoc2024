import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam_community/maths/elementary
import solution
import util

pub fn solution() {
  solution.Solution(
    day: 7,
    example: "
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20",
    part1: fn(input) {
      input
      |> util.lines_trimmed
      |> list.filter_map(fn(line) {
        let #(total, inputs) = parse_equation(line)
        evaluate_add_mult(total, inputs)
      })
      |> int.sum
    },
    part2: fn(input) {
      input
      |> util.lines_trimmed
      |> list.filter_map(fn(line) {
        let #(total, inputs) = parse_equation(line)
        evaluate_add_mult_concat(total, inputs)
      })
      |> int.sum
    },
  )
}

fn parse_equation(input: String) {
  let assert Ok(#(total, inputs)) = input |> string.split_once(": ")
  let assert Ok(total) = int.parse(total)
  let assert Ok(inputs) =
    inputs |> string.split(" ") |> list.map(int.parse) |> result.all
  #(total, inputs)
}

fn evaluate_add_mult(total: Int, inputs: List(Int)) {
  case inputs {
    [] -> panic as "equation was empty"
    [input] -> {
      case total == input {
        True -> Ok(total)
        False -> Error(Nil)
      }
    }
    [a, b, ..rest] -> {
      evaluate_add_mult(total, [a * b, ..rest])
      |> result.lazy_or(fn() { evaluate_add_mult(total, [a + b, ..rest]) })
    }
  }
}

fn evaluate_add_mult_concat(total: Int, inputs: List(Int)) {
  case inputs {
    [] -> panic as "equation was empty"
    [input] -> {
      case total == input {
        True -> Ok(total)
        False -> Error(Nil)
      }
    }
    [a, b, ..rest] -> {
      evaluate_add_mult_concat(total, [a * b, ..rest])
      |> result.lazy_or(fn() {
        evaluate_add_mult_concat(total, [a + b, ..rest])
      })
      |> result.lazy_or(fn() {
        evaluate_add_mult_concat(total, [int_concat(a, b), ..rest])
      })
    }
  }
}

// we could do this with strings, but using math instead is fun and powerful :)
fn int_concat(a: Int, b: Int) {
  // the log10 is, in rough terms, the number of tens a number has. example:
  // log10(10) = 1
  // log10(50) = ~1.69
  // log10(100) = 2
  let assert Ok(power) = b |> int.to_float |> elementary.logarithm_10

  // we can get the number of digits by flooring the log and adding 1
  let power = float.floor(power) +. 1.0

  // then, we can do 10 ** power for a tens multiplier with zeros equal to the digit count
  // 10 ** 1 = 10
  // 10 ** 2 = 100
  // 10 ** 3 = 1000
  let assert Ok(multiplier) = int.power(10, power)

  // multiply our result by that number, and we add zeros which "make space"
  // for the value being added, effectively turning into a concat
  // example:
  // a = 123
  // b = 45
  // power = ceil(log10(value)) = 2
  // result = a * (10 ** power) + b = 123 * 100 + 45 = 12300 + 45 = 12345
  a * float.truncate(multiplier) + b
}
