import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lib/solution
import simplifile
import solutions

pub fn main() {
  let argv.Argv(arguments:, ..) = argv.load()
  case arguments {
    ["gen", day] -> {
      let assert Ok(day) = int.parse(day)
      generate_day(day)
    }
    _ -> {
      let printer = solution.printer(arguments)
      solutions.run(printer)
    }
  }
}

const solutions_file = "src/solutions.gleam"

fn generate_day(day: Int) {
  let day_str = int.to_string(day) |> string.pad_start(2, "0")
  let dir = "src/day" <> day_str
  let module_file = dir <> "/day" <> day_str <> ".gleam"
  let input_file = dir <> "/input.txt"

  // Create the new day's files
  let assert Ok(_) = simplifile.create_directory_all(dir)
  let assert Ok(_) = simplifile.write(input_file, "")
  let assert Ok(_) = simplifile.write(module_file, "import gleam/list
import gleam/string
import lib/solution.{Solution}
import lib/util

const example_input = \"\"

pub fn solution() {
  Solution(day: " <> int.to_string(day) <> ", example: example_input, part1:, part2:)
}

fn part1(input: String) {
  todo
}

fn part2(input: String) {
  todo
}
")

  // Generate the entire solutions file
  let imports =
    list.range(1, day)
    |> list.map(fn(d) {
      let d_str = int.to_string(d) |> string.pad_start(2, "0")
      "import day" <> d_str <> "/day" <> d_str
    })
    |> string.join("\n")

  let solution_calls =
    list.range(1, day)
    |> list.map(fn(d) {
      let d_str = int.to_string(d) |> string.pad_start(2, "0")
      "  |> solution.print(day" <> d_str <> ".solution())"
    })
    |> string.join("\n")

  let new_content =
    [
      imports,
      "import lib/solution",
      "",
      "pub fn run(printer: solution.SolutionPrinter) {",
      "  printer",
      solution_calls,
      "  Nil",
      "}",
      "",
    ]
    |> string.join("\n")

  let assert Ok(_) = simplifile.write(solutions_file, new_content)

  io.println("Generated " <> module_file)
  io.println("Generated " <> input_file)
  io.println("Updated " <> solutions_file)
}
