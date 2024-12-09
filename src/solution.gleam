import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile
import tempo/duration
import tobble

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
  use <- bool.guard(!is_enabled(printer.day_filter, solution.day), printer)

  let assert Ok(input) =
    result.or(
      simplifile.read("src/day" <> int.to_string(solution.day) <> ".txt"),
      simplifile.read("src/day" <> int.to_string(solution.day) <> "/input.txt"),
    )

  let part_rows = [
    #(Part1ExampleSolution, "Part 1e", fn() {
      string.inspect(solution.part1(solution.example))
    }),
    #(Part2ExampleSolution, "Part 2e", fn() {
      string.inspect(solution.part2(solution.example))
    }),
    #(Part1Solution, "Part 1", fn() { string.inspect(solution.part1(input)) }),
    #(Part2Solution, "Part 2", fn() { string.inspect(solution.part2(input)) }),
  ]

  let table =
    tobble.builder()
    |> tobble.add_row(["Day " <> int.to_string(solution.day), "Result", "Time"])

  let assert Ok(table) =
    part_rows
    |> list.filter(fn(row) { is_enabled(printer.part_filter, row.0) })
    |> list.fold(table, fn(table, row) {
      let timer = duration.start_monotonic()
      let result = row.2()
      let duration = duration.since(timer)
      table |> tobble.add_row([row.1, result, duration])
    })
    |> tobble.build()

  io.println(tobble.render(table))

  printer
}

fn is_enabled(set: set.Set(a), value: a) {
  set.is_empty(set) || set.contains(set, value)
}
