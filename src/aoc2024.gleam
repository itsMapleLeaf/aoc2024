import argv
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import gleam_community/ansi
import glenvy/dotenv
import glenvy/env
import lib/solution
import lib/util
import simplifile
import solutions
import spinner

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

fn fetch_input(day: Int) {
  use _ <- result.try(dotenv.load() |> result.map_error(string.inspect))

  use session <- result.try(
    env.get_string("SESSION") |> result.map_error(string.inspect),
  )

  let url =
    "https://adventofcode.com/2024/day/" <> int.to_string(day) <> "/input"

  use request <- result.try(
    request.to(url)
    |> result.map_error(string.inspect),
  )

  use response <- result.try(
    request.set_header(request, "cookie", "session=" <> session)
    |> httpc.send
    |> result.map_error(string.inspect),
  )

  Ok(response.body)
}

fn generate_day(day: Int) {
  let day_str = int.to_string(day) |> string.pad_start(2, "0")
  let dir = "src/day" <> day_str
  let module_file = dir <> "/day" <> day_str <> ".gleam"
  let input_file = dir <> "/input.txt"

  let spinner =
    spinner.new("Fetching input")
    |> spinner.with_colour(ansi.blue)
    |> spinner.start

  let input = case fetch_input(day) {
    Ok(input) -> {
      util.assert_ok(regexp.from_string("\\n$"))
      |> regexp.replace(input, "")
    }
    Error(error) -> {
      io.println_error("Failed to fetch input: " <> error)
      ""
    }
  }

  spinner |> spinner.stop

  let assert Ok(_) = simplifile.create_directory_all(dir)
  io.println("Created " <> dir)

  let assert Ok(_) = simplifile.write(input_file, input)
  io.println("Saved " <> input_file)

  let assert Ok(_) = simplifile.write(module_file, module_template(day))
  io.println("Saved " <> module_file)

  let assert Ok(_) = simplifile.write(solutions_file, solutions_template(day))
  io.println("Saved " <> solutions_file)
}

fn module_template(day: Int) {
  "import gleam/list
import gleam/string
import lib/solution.{Solution}
import lib/util

const example_input = \"\"

pub fn solution() {
  Solution(day: " <> int.to_string(day) <> ", example: example_input, part1:, part2:)
}

fn part1(input: String) {
  0
}

fn part2(input: String) {
  0
}
"
}

fn solutions_template(day: Int) {
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

  imports <> "
import lib/solution

pub fn run(printer: solution.SolutionPrinter) {
  printer
" <> solution_calls <> "
  Nil
}
"
}
