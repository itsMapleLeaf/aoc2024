import argv
import day01/day01
import day02/day02
import day03/day03
import day04/day04
import day05/day05
import day06/day06
import day07/day07
import lib/solution

pub fn main() {
  let argv.Argv(arguments:, ..) = argv.load()
  solution.printer(arguments)
  |> solution.print(day01.solution())
  |> solution.print(day02.solution())
  |> solution.print(day03.solution())
  |> solution.print(day04.solution())
  |> solution.print(day05.solution())
  |> solution.print(day06.solution())
  |> solution.print(day07.solution())
}
