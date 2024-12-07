import argv
import day1
import day2
import day3
import day4
import day5
import day6/day6
import solution

pub fn main() {
  let argv.Argv(arguments:, ..) = argv.load()
  solution.printer(arguments)
  |> solution.print(day1.solution())
  |> solution.print(day2.solution())
  |> solution.print(day3.solution())
  |> solution.print(day4.solution())
  |> solution.print(day5.solution())
  |> solution.print(day6.solution())
}
