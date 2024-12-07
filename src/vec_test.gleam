import gleeunit/should
import vec

pub fn rotate_right_test() {
  vec.rotate_right(vec.down) |> should.equal(vec.left)
  vec.rotate_right(vec.left) |> should.equal(vec.up)
  vec.rotate_right(vec.up) |> should.equal(vec.right)
  vec.rotate_right(vec.right) |> should.equal(vec.down)
  vec.rotate_right(vec.zero) |> should.equal(vec.zero)
}
