import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string

pub fn counts(of values: List(a)) -> dict.Dict(a, Int) {
  list.fold(values, dict.new(), fn(counts, id) {
    dict.upsert(counts, id, fn(count) { option.unwrap(count, 0) + 1 })
  })
}

pub fn assert_ok(result: Result(a, b)) -> a {
  let assert Ok(value) = result
  value
}

pub fn assert_parse_int(input: String) {
  case int.parse(input) {
    Ok(int) -> int
    Error(_) -> panic as { "invalid int: " <> input }
  }
}

pub fn lines(text: String) {
  text |> string.split("\n")
}
