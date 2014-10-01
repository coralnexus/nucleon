module Nucleon
module Mixin
#
# == Console colors
#
# The Nucleon::Mixin::Colors module extends a class or instance to include
# methods for wrapping strings in colored text markers.
#
# For usage and definition:
#
# - See Nucleon::Util::Console
#
module Colors

  # Return a given string wrapped in black text markers.
  #
  # See:
  # - Nucleon::Util::Console::black
  #
  def black(string)
    ::Nucleon::Util::Console.black(string)
  end

  # Return a given string wrapped in red text markers.
  #
  # See:
  # - Nucleon::Util::Console::red
  #
  def red(string)
    ::Nucleon::Util::Console.red(string)
  end

  # Return a given string wrapped in green text markers.
  #
  # See:
  # - Nucleon::Util::Console::green
  #
  def green(string)
    ::Nucleon::Util::Console.green(string)
  end

  # Return a given string wrapped in yellow text markers.
  #
  # See:
  # - Nucleon::Util::Console::yellow
  #
  def yellow(string)
    ::Nucleon::Util::Console.yellow(string)
  end

  # Return a given string wrapped in blue text markers.
  #
  # See:
  # - Nucleon::Util::Console::blue
  #
  def blue(string)
    ::Nucleon::Util::Console.blue(string)
  end

  # Return a given string wrapped in purple text markers.
  #
  # See:
  # - Nucleon::Util::Console::purple
  #
  def purple(string)
    ::Nucleon::Util::Console.purple(string)
  end

  # Return a given string wrapped in cyan text markers.
  #
  # See:
  # - Nucleon::Util::Console::cyan
  #
  def cyan(string)
    ::Nucleon::Util::Console.cyan(string)
  end

  # Return a given string wrapped in grey text markers.
  #
  # See:
  # - Nucleon::Util::Console::grey
  #
  def grey(string)
    ::Nucleon::Util::Console.grey(string)
  end
end
end
end

