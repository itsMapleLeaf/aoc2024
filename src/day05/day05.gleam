import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import lib/solution.{Solution}
import lib/util

pub fn solution() {
  Solution(
    day: 5,
    example: "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47",
    part1: fn(input) {
      let #(rules, page_lists) = parse_input(input)
      let valid_lists = page_lists |> list.filter(is_valid(_, rules))
      let middle_numbers = middle_numbers(valid_lists)
      int.sum(middle_numbers)
    },
    part2: fn(input) {
      let #(rules, page_lists) = parse_input(input)
      page_lists
      |> list.filter_map(fn(page_numbers) {
        let fixed = fixed_invalid_list(set.from_list(page_numbers), rules)
        case fixed != page_numbers {
          True -> Ok(fixed)
          False -> Error(Nil)
        }
      })
      |> middle_numbers
      |> int.sum
    },
  )
}

fn parse_input(input: String) {
  let assert Ok(#(rules, page_lists)) =
    input |> string.trim |> string.split_once("\n\n")
  let rules = parse_rules(rules)
  let page_lists = parse_page_lists(page_lists)
  #(rules, page_lists)
}

fn parse_rules(rules: String) -> Dict(Int, Set(Int)) {
  rules
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(a), Ok(b)] = line |> string.split("|") |> list.map(int.parse)
    #(a, b)
  })
  |> list.fold(dict.new(), fn(dict, pair) {
    dict.upsert(dict, pair.0, fn(set) {
      option.unwrap(set, set.new())
      |> set.union(set.from_list([pair.1]))
    })
  })
}

fn parse_page_lists(page_lists: String) -> List(List(Int)) {
  page_lists
  |> string.split("\n")
  |> list.map(string.split(_, ","))
  |> list.map(list.map(_, util.assert_parse_int))
}

fn middle_numbers(lists: List(List(Int))) -> List(Int) {
  lists
  |> list.map(fn(list) {
    list
    |> list.drop(list.length(list) / 2)
    |> list.first
    |> util.assert_ok
  })
}

fn is_valid(list: List(Int), rules: Dict(Int, Set(Int))) -> Bool {
  case list {
    [] -> panic
    [_] -> True
    [first, next, ..rest] -> {
      case dict.get(rules, first) {
        Error(_) -> False
        Ok(destinations) -> {
          case set.contains(destinations, next) {
            False -> False
            True -> is_valid([next, ..rest], rules)
          }
        }
      }
    }
  }
}

fn fixed_invalid_list(page_numbers: Set(Int), rules: Dict(Int, Set(Int))) {
  case set.size(page_numbers) {
    0 -> panic
    1 -> set.to_list(page_numbers)
    _ -> {
      // get the item where it has a rule entry for every following
      let assert Ok(#(head, rest)) =
        page_numbers
        |> set.to_list
        |> list.find_map(fn(head) {
          let rest = page_numbers |> set.delete(head)
          use following <- result.try(dict.get(rules, head))
          case rest |> set.is_subset(following) {
            True -> Ok(#(head, rest))
            False -> Error(Nil)
          }
        })

      [head, ..fixed_invalid_list(rest, rules)]
    }
  }
}
