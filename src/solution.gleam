import gleam/int
import gleam/io
import gleam/result
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

pub fn print(solution: Solution(a, b)) {
  let Solution(day:, example:, part1:, part2:) = solution
  let day = int.to_string(day)

  let assert Ok(input) =
    result.or(
      simplifile.read("src/day" <> day <> ".txt"),
      simplifile.read("src/day" <> day <> "/input.txt"),
    )

  io.println("--- Day " <> day <> " ---")
  io.println("Part 1 (example): " <> string.inspect(part1(example)))
  io.println("Part 2 (example): " <> string.inspect(part2(example)))
  io.println("Part 1: " <> string.inspect(part1(input)))
  io.println("Part 2: " <> string.inspect(part2(input)))
}
