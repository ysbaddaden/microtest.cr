macro describe(name)
  struct {{name.id.stringify.camelcase.id}}Spec < Microtest::Spec
    {{yield}}
  end
end

abstract struct Microtest::Spec < Microtest::Test
  macro let(name)
    def {{name.id}}
      @{{name.id}} ||= begin; {{ yield }}; end
    end
  end

  macro before
    def setup
      {{yield}}
      super()
    end
  end

  macro after
    def teardown
      {{yield}}
      super()
    end
  end

  macro describe(name)
    {% raise "ERROR: can't nest spec contexts (can't inherit from non abstract struct)" %}
  end

  macro it(name)
    def test_{{name.id.stringify.gsub(/\s+/, "_").id}}
      {{yield}}
    end
  end
end
