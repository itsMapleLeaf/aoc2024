import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import util
import vec.{type Vec}

pub type Board {
  Board(
    size: Vec,
    position: Vec,
    start_position: Vec,
    direction: Vec,
    obstacles: Set(Vec),
    path: List(PathStop),
  )
}

pub type PathStop {
  PathStop(position: Vec, direction: Vec)
}

pub fn from_input(input: String) {
  let input_lines =
    input
    |> string.trim_start
    |> util.lines
    |> list.map(string.trim_start)

  let size =
    vec.of(
      input_lines |> list.first |> util.assert_ok |> string.length,
      input_lines |> list.length,
    )

  let input_symbol_grid =
    input_lines
    |> list.index_map(fn(line, y) {
      line
      |> string.trim_start
      |> string.to_graphemes
      |> list.index_map(fn(symbol, x) {
        let position = vec.of(x, y)
        #(position, symbol)
      })
    })
    |> list.flatten

  let assert Ok(#(position, direction)) =
    list.find_map(input_symbol_grid, fn(cell) {
      case cell {
        #(position, "^") -> Ok(#(position, vec.up))
        #(position, "<") -> Ok(#(position, vec.left))
        #(position, ">") -> Ok(#(position, vec.right))
        #(position, "V") -> Ok(#(position, vec.down))
        _ -> Error(Nil)
      }
    })

  let obstacles =
    list.filter_map(input_symbol_grid, fn(cell) {
      case cell {
        #(position, "#") -> Ok(position)
        _ -> Error(Nil)
      }
    })
    |> set.from_list

  Board(
    size:,
    position:,
    start_position: position,
    direction:,
    obstacles:,
    path: [PathStop(position:, direction:)],
  )
}

pub fn count_loop_obstructions(board: Board) {
  let assert Completed(completed_board) = complete_patrol(board)

  completed_board.path
  // the path is constructed from end to start,
  // so reverse to get a path from the start
  |> list.reverse
  // turn the list into segments [(Vec(0, 0), Vec(0, 5)), (Vec(0, 5), Vec(5, 5)), ...]
  |> list.window_by_2
  |> list.flat_map(fn(segment) {
    let #(a, b) = get_path_segment_vectors(segment)
    vec.range(a, b) |> yielder.drop(1) |> yielder.to_list
  })
  |> list.unique
  |> list.count(fn(point) {
    let board_with_new_obstruction =
      Board(..board, obstacles: set.insert(board.obstacles, point))

    case complete_patrol(board_with_new_obstruction) {
      Completed(..) -> False
      Looping -> True
    }
  })
}

fn move_to(
  board: Board,
  destination position: Vec,
  facing_towards direction: Vec,
) {
  Board(
    ..board,
    position:,
    direction:,
    path: [PathStop(position:, direction:), ..board.path],
  )
}

fn get_edge_facing_point(board: Board) {
  board.position
  |> vec.add(vec.multiply(board.direction, board.size))
  |> vec.clamp(vec.zero, board.size |> vec.subtract(vec.one))
}

type PatrolResult {
  Completed(Board)
  Looping
}

fn complete_patrol(board: Board) -> PatrolResult {
  case is_looping(board) {
    True -> Looping
    False -> {
      let edge_point = get_edge_facing_point(board)

      let obstruction_result =
        vec.range(board.position, edge_point)
        |> yielder.find(set.contains(board.obstacles, _))

      case obstruction_result {
        Ok(position) -> {
          complete_patrol(
            board
            |> move_to(
              position |> vec.subtract(board.direction),
              board.direction |> vec.rotate_right,
            ),
          )
        }
        Error(_) -> Completed(board |> move_to(edge_point, board.direction))
      }
    }
  }
}

fn is_looping(board: Board) {
  board.path
  |> list.drop(1)
  |> list.any(fn(stop) {
    stop.position == board.position && stop.direction == board.direction
  })
}

type PathSegment =
  #(PathStop, PathStop)

fn get_path_segment_vectors(segment: PathSegment) {
  let #(a, b) = segment
  #(a.position, b.position)
}
