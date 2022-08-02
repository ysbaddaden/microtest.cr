module Microtest
  struct Result
    def initialize(@suite_name : String, @method_name : String)
      @failed = false
      @duration = 0.0
    end

    def suite_name : String
      @suite_name
    end

    def method_name : String
      @method_name
    end

    def duration : Float64
      @duration
    end

    def duration=(value : Float64)
      @duration = value
    end

    def failed! : Nil
      @failed = true
    end

    def failed? : Bool
      @failed == true
    end
  end
end
