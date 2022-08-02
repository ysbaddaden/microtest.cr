require "./result"

abstract struct Microtest::Test
  def self.run_suite : Nil
    {% for method in @type.methods %}
      {% if method.name.starts_with?("test_") %}
        Microtest.count &+= 1

        result = Microtest::Result.new({{@type.name.stringify}}, {{method.name.stringify}})
        %test = new

        result.duration = Microtest.measure do
          %test.setup
          result.status = %test.{{method.name}}
          %test.teardown
        end

        Microtest.report(result)
      {% end %}
    {% end %}
  end

  def setup : Nil
  end

  def teardown : Nil
  end

  macro skip
    return Microtest::Status::SKIP
  end

  macro assert(expression, file = __FILE__, line = __LINE__)
    unless !!({{expression}}) == true
      LibC.dprintf(2, "Expected {{expression}} to be truthy\n")
      LibC.dprintf(2, "  at %s:%d\n", {{file}}, {{line}})
      return Microtest::Status::FAILURE
    end
  end

  macro refute(expression, file = __FILE__, line = __LINE__)
    unless !!({{expression}}) == false
      LibC.dprintf(2, "\nExpected {{expression}} to be falsy\n")
      LibC.dprintf(2, "  at %s:%d\n", {{file}}, {{line}})
      return Microtest::Status::FAILURE
    end
  end
end
