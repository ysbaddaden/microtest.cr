require "lib_c"
require "c/errno"
require "c/stdlib"
require "c/stdio"
require "c/string"

# fun __crystal_raise_overflow : NoReturn
#   abort "math overflow error"
# end

class String
  def to_unsafe : UInt8*
    pointerof(@c)
  end
end

struct StaticArray
  def to_unsafe : Pointer(T)
    pointerof(@buffer)
  end
end

lib LibC
  # FIXME: these should be in c/errno!
  {% if flag?(:linux) || flag?(:dragonfly) %}
    fun __errno_location : Int*
  {% elsif flag?(:wasi) %}
    $errno : Int
  {% elsif flag?(:darwin) || flag?(:freebsd) %}
    fun __error : Int*
  {% elsif flag?(:netbsd) || flag?(:openbsd) %}
    fun __error = __errno : Int*
  {% elsif flag?(:win32) %}
    fun _get_errno(value : Int*) : ErrnoT
    fun _set_errno(value : Int) : ErrnoT
  {% end %}
end

def errno : Int32
  {% if flag?(:linux) || flag?(:dragonfly) %}
    LibC.__errno_location.value
  {% elsif flag?(:darwin) || flag?(:bsd) %}
    LibC.__error.value
  {% elsif flag?(:win32) %}
    ret = LibC._get_errno(out errno)
    abort("ERROR: _get_errno failed") unless ret == 0
    errno
  {% end %}
end

def unreachable : NoReturn
  panic "BUG: unreachable has been reached (oops)"
end

def abort(message) : NoReturn
  LibC.dprintf(2, message)
  LibC.dprintf(2, "\n")
  LibC.exit(1)
end

def panic(function_name, errnum = errno) : NoReturn
  LibC.dprintf(2, "ERROR: %s failed with %s\n", function_name, LibC.strerror(errnum))
  LibC.exit(1)
end
