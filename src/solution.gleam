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

pub opaque type SolutionPrinter {
  SolutionPrinter(
    day_filter: set.Set(Int),
    part_filter: set.Set(SolutionPart),
    ugly: Bool,
  )
}

type SolutionPart {
  Part1
  Part2
  Part1Example
  Part2Example
}

pub fn printer(cli_args: List(String)) {
  list.fold(
    cli_args,
    SolutionPrinter(day_filter: set.new(), part_filter: set.new(), ugly: False),
    fn(printer, arg) {
      case arg {
        "d" <> num -> {
          let assert Ok(day) = int.parse(num)
          printer |> with_day(day)
        }
        "p1" -> printer |> with_part(Part1)
        "p2" -> printer |> with_part(Part2)
        "p1e" -> printer |> with_part(Part1Example)
        "p2e" -> printer |> with_part(Part2Example)
        "--ugly" -> SolutionPrinter(..printer, ugly: True)
        _ -> panic as { "invalid arg " <> arg }
      }
    },
  )
}

fn with_day(printer: SolutionPrinter, day: Int) {
  SolutionPrinter(..printer, day_filter: set.insert(printer.day_filter, day))
}

fn with_part(printer: SolutionPrinter, part: SolutionPart) {
  SolutionPrinter(..printer, part_filter: set.insert(printer.part_filter, part))
}

fn is_enabled(enabled_values: set.Set(a), value: a) {
  case set.size(enabled_values) {
    0 -> True
    _ -> enabled_values |> set.contains(value)
  }
}

pub fn print(printer: SolutionPrinter, solution: Solution(a, b)) {
  use <- bool.guard(!is_enabled(printer.day_filter, solution.day), printer)

  let assert Ok(input) =
    result.or(
      simplifile.read("src/day" <> int.to_string(solution.day) <> ".txt"),
      simplifile.read("src/day" <> int.to_string(solution.day) <> "/input.txt"),
    )

  let part_rows =
    [
      #(Part1Example, "Part 1e", fn() {
        string.inspect(solution.part1(solution.example))
      }),
      #(Part1, "Part 1", fn() { string.inspect(solution.part1(input)) }),
      #(Part2Example, "Part 2e", fn() {
        string.inspect(solution.part2(solution.example))
      }),
      #(Part2, "Part 2", fn() { string.inspect(solution.part2(input)) }),
    ]
    |> list.filter(fn(row) { is_enabled(printer.part_filter, row.0) })

  case printer.ugly {
    True -> {
      io.println("--- Day " <> int.to_string(solution.day) <> " ---")
      list.each(part_rows, fn(row) {
        let timer = duration.start_monotonic()
        let result = row.2()
        let duration = duration.since(timer)
        io.println(row.1 <> ": " <> result <> " (" <> duration <> ")")
      })
    }
    False -> {
      let table =
        tobble.builder()
        |> tobble.add_row([
          "Day " <> int.to_string(solution.day),
          "Result",
          "Time",
        ])

      let assert Ok(table) =
        part_rows
        |> list.fold(table, fn(table, row) {
          let timer = duration.start_monotonic()
          let result = row.2()
          let duration = duration.since(timer)
          table |> tobble.add_row([row.1, result, duration])
        })
        |> tobble.build()

      io.println(tobble.render(table))
    }
  }

  printer
}
