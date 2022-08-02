require "c/string"
require "./microtest"

Microtest.configure do |options|
  i = 0
  while (i &+= 1) < ARGC_UNSAFE
    value = (ARGV_UNSAFE + i).value

    if LibC.strcmp("-v", value) == 0 || LibC.strcmp("--verbose", value) == 0
      options.value.verbose = true
    end

    if LibC.strcmp("--no-color", value) == 0
      options.value.colorful = false
    end
  end
end

success = Microtest.run
LibC.exit(success ? 0 : 1)
