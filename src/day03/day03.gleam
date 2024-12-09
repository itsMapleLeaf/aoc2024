import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}
import lib/solution.{Solution}

pub fn solution() {
  Solution(
    day: 3,
    example: "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
    part1: fn(input) {
      mul_instruction_exp()
      |> regexp.scan(input)
      |> list.map(fn(match) {
        let assert [Some(x), Some(y)] = match.submatches
        let assert #(Ok(x), Ok(y)) = #(int.parse(x), int.parse(y))
        x * y
      })
      |> int.sum
    },
    part2: interpret,
  )
}

const mul_instruction_exp_string = "mul\\((\\d{1,3}),(\\d{1,3})\\)"

fn mul_instruction_exp() {
  let assert Ok(exp) = regexp.from_string(mul_instruction_exp_string)
  exp
}

fn interpret(input: String) {
  let assert Ok(instruction_exp) =
    regexp.from_string(mul_instruction_exp_string <> "|do\\(\\)|don't\\(\\)")

  instruction_exp
  |> regexp.scan(input)
  |> list.fold(#(0, True), fn(state, inst) {
    case inst {
      Match(content: "mul(" <> _, submatches: [Some(x), Some(y)]) -> {
        case state {
          #(_, False) -> state
          #(sum, enabled) -> {
            let assert #(Ok(x), Ok(y)) = #(int.parse(x), int.parse(y))
            #(sum + { x * y }, enabled)
          }
        }
      }
      Match(content: "do()", ..) -> {
        #(state.0, True)
      }
      Match(content: "don't()", ..) -> {
        #(state.0, False)
      }
      _ -> panic
    }
  })
}
