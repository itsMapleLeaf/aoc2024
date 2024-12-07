import argv
import day1
import day2
import day3
import day4
import gleam/int
import gleam/list
import gleam/set
import solution.{SolutionConfig}

pub fn main() {
  let argv.Argv(arguments: args, ..) = argv.load()

  let config =
    SolutionConfig(
      print_days: args
        |> list.filter_map(parse_day_arg)
        |> set.from_list,
      print_parts: args
        |> list.filter_map(parse_part_arg)
        |> set.from_list,
    )

  config
  |> solution.print(day1.solution())
  |> solution.print(day2.solution())
  |> solution.print(day3.solution())
  |> solution.print(day4.solution())
}

fn parse_day_arg(arg) {
  case arg {
    "d" <> rest -> int.parse(rest)
    _ -> Error(Nil)
  }
}

fn parse_part_arg(arg) {
  case arg {
    "p1" -> Ok(solution.Part1Solution)
    "p2" -> Ok(solution.Part2Solution)
    "p1e" -> Ok(solution.Part1ExampleSolution)
    "p2e" -> Ok(solution.Part2ExampleSolution)
    _ -> Error(Nil)
  }
}
