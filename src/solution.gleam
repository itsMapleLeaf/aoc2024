import gleam/int
import gleam/io
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub type Solution(a, b) {
  Solution(
    day: Int,
    example: String,
    part1: fn(String) -> a,
    part2: fn(String) -> b,
  )
}

pub type SolutionConfig {
  SolutionConfig(print_days: set.Set(Int), print_parts: set.Set(SolutionPart))
}

pub type SolutionPart {
  Part1Solution
  Part2Solution
  Part1ExampleSolution
  Part2ExampleSolution
}

pub fn print(config: SolutionConfig, solution: Solution(a, b)) {
  let Solution(day:, example:, part1:, part2:) = solution
  let day = int.to_string(day)

  let assert Ok(input) =
    result.or(
      simplifile.read("src/day" <> day <> ".txt"),
      simplifile.read("src/day" <> day <> "/input.txt"),
    )

  case is_configured(config.print_days, solution.day) {
    False -> Nil
    True -> {
      io.println("--- Day " <> day <> " ---")
      print_if(
        is_configured(config.print_parts, Part1ExampleSolution),
        "Part 1 (example): " <> string.inspect(part1(example)),
      )
      print_if(
        is_configured(config.print_parts, Part2ExampleSolution),
        "Part 2 (example): " <> string.inspect(part2(example)),
      )
      print_if(
        is_configured(config.print_parts, Part1Solution),
        "Part 1: " <> string.inspect(part1(input)),
      )
      print_if(
        is_configured(config.print_parts, Part2Solution),
        "Part 2: " <> string.inspect(part2(input)),
      )
    }
  }

  config
}

fn is_configured(set: set.Set(a), value: a) {
  set.is_empty(set) || set.contains(set, value)
}

fn print_if(condition: Bool, text: String) {
  case condition {
    False -> Nil
    True -> io.println(text)
  }
}
