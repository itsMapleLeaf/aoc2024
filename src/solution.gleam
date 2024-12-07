import gleam/int
import gleam/io
import gleam/list
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

pub type SolutionPrinter {
  SolutionPrinter(day_filter: set.Set(Int), part_filter: set.Set(SolutionPart))
}

pub type SolutionPart {
  Part1Solution
  Part2Solution
  Part1ExampleSolution
  Part2ExampleSolution
}

pub fn printer(cli_args: List(String)) {
  SolutionPrinter(
    day_filter: cli_args
      |> list.filter_map(parse_day_arg)
      |> set.from_list,
    part_filter: cli_args
      |> list.filter_map(parse_part_arg)
      |> set.from_list,
  )
}

fn parse_day_arg(arg) {
  case arg {
    "d" <> rest -> int.parse(rest)
    "p" <> _ -> Error(Nil)
    _ -> panic as { "invalid arg " <> arg }
  }
}

fn parse_part_arg(arg) {
  case arg {
    "p1" -> Ok(Part1Solution)
    "p2" -> Ok(Part2Solution)
    "p1e" -> Ok(Part1ExampleSolution)
    "p2e" -> Ok(Part2ExampleSolution)
    "d" <> _ -> Error(Nil)
    _ -> panic as { "invalid arg " <> arg }
  }
}

pub fn print(printer: SolutionPrinter, solution: Solution(a, b)) {
  let Solution(day:, example:, part1:, part2:) = solution

  let assert Ok(input) =
    result.or(
      simplifile.read("src/day" <> int.to_string(day) <> ".txt"),
      simplifile.read("src/day" <> int.to_string(day) <> "/input.txt"),
    )

  printer
  |> print_day(day, fn() {
    printer
    |> print_part(Part1ExampleSolution, "Part 1e", fn() { part1(example) })
    |> print_part(Part2ExampleSolution, "Part 2e", fn() { part2(example) })
    |> print_part(Part1Solution, "Part 1", fn() { part1(input) })
    |> print_part(Part2Solution, "Part 2", fn() { part2(input) })
  })
}

fn print_day(printer: SolutionPrinter, day: Int, func: fn() -> a) {
  case is_enabled(printer.day_filter, day) {
    False -> Nil
    True -> {
      io.println("--- Day " <> int.to_string(day) <> " ---")
      func()
      Nil
    }
  }
  printer
}

fn print_part(
  printer: SolutionPrinter,
  part: SolutionPart,
  prefix: String,
  result: fn() -> a,
) {
  case is_enabled(printer.part_filter, part) {
    False -> Nil
    True -> io.println(prefix <> ": " <> string.inspect(result()))
  }
  printer
}

fn is_enabled(set: set.Set(a), value: a) {
  set.is_empty(set) || set.contains(set, value)
}
