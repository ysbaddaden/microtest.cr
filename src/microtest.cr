require "c/stdlib"
require "c/sys/time"
require "c/time"
require "./corelib"
require "./options"
require "./test"

module Microtest
  @@count = 0
  @@failures = 0
  @@total_duration = 0.0
  @@options = Options.new

  def self.count
    @@count
  end

  protected def self.count=(value : Int32)
    @@count = value
  end

  def self.failures
    @@failures
  end

  def self.total_duration
    @@total_duration
  end

  def self.configure(& : Pointer(Options) ->) : Nil
    yield pointerof(@@options)
  end

  def self.failed?
    @@failures > 0
  end

  def self.run : Bool
    {% for suite in Microtest::Test.all_subclasses %}
      {{ suite.name }}.run_suite
    {% end %}

    if @@options.verbose?
      LibC.dprintf(2, "\n")
    else
      LibC.dprintf(2, "\n\n")
    end

    color, reset = colors(failed?)

    LibC.dprintf(2, "Finished in %s\n", humanize(total_duration))
    LibC.dprintf(2, "%s%d runs, %d failures%s\n", color, count, failures, reset)

    !failed?
  end

  protected def self.measure : Float64?
    start = clock_gettime(LibC::CLOCK_MONOTONIC)
    yield
    stop = clock_gettime(LibC::CLOCK_MONOTONIC)
    (stop[0] &- start[0]).to_f + (stop[1] &- start[1]).to_f / 1_000_000_000.0
  end

  private def self.clock_gettime(clock : LibC::ClockidT) : {Int64, Int32}
    if LibC.clock_gettime(clock, out tp) == 1
      panic "clock_gettime"
    end
    {tp.tv_sec.to_i64!, tp.tv_nsec.to_i32!}
  end

  protected def self.report(result : Result) : Nil
    if result.failed?
      @@failures &+= 1
      char = "F"
    else
      char = "."
    end

    @@total_duration += result.duration
    color, reset = colors(result.failed?)

    if @@options.verbose?
      LibC.dprintf(2, "%s#%s (%s) = %s%s%s\n", result.suite_name, result.method_name, humanize(result.duration), color, char, reset)
    else
      LibC.dprintf(2, "%s%s%s", color, char, reset)
    end
  end

  private def self.colors(failed)
    if @@options.colorful?
      {failed ? "\e[31" : "\e[32m", "\e[0m"}
    else
      {"", ""}
    end
  end

  @[AlwaysInline]
  private def self.humanize(duration : Float64)
    if duration < 0.000_001
      format = "%.f ns"
      duration *= 1_000_000_000
    elsif duration < 0.001
      format = "%.3f us"
      duration *= 1_000_000
    elsif duration < 1.0
      format = "%.3f ms"
      duration *= 1_000
    else
      format = "%.3f s"
    end

    str = uninitialized UInt8[20]
    LibC.snprintf(str, 20, format, duration)
    str
  end
end
