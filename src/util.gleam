import gleam/dict
import gleam/list
import gleam/option

pub fn counts(of values: List(a)) -> dict.Dict(a, Int) {
  list.fold(values, dict.new(), fn(counts, id) {
    dict.upsert(counts, id, fn(count) { option.unwrap(count, 0) + 1 })
  })
}
