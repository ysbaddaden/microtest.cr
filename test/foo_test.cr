require "../src/autorun"

struct FooTest < Microtest::Test
  def test_bar
    assert true
    refute false
  end
end
