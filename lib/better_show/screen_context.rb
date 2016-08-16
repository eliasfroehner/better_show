require 'rubyserial'

module BetterShow
  # Implementation of ANSI/VT100 commands => http://odroid.com/dokuwiki/doku.php?id=en:show_using
  # Some code logic used from https://github.com/Matoking/SHOWtime/blob/master/context.py

  class ScreenContext
    include BetterShow

    class ConnectionError < RuntimeError
    end
    class NoConnectionError < RuntimeError
    end

    attr_accessor :device_port
    attr_accessor :buffered_write
    attr_reader :buffer

    # @param port Serialport
    # @param buffered All functions will be buffered => use flush to transmit to device
    def initialize(port = "/dev/ttyUSB0", buffered = true)
      @device_port = port
      @device = nil
      @buffered_write = buffered
      @buffer = ""

      @characters_on_current_row = 0
      @orientation = Screen.VERTICAL
    end

    # Connect to ODROID-SHOW
    def connect!
      begin
        @device = Serial.new @device_port, 500000
      rescue RubySerial::Exception => e
        raise ConnectionError, e.message
      end
    end

    # Disconnect to ODROID-SHOW
    def disconnect!
      reset_lcd
      set_text_size(2)
      set_rotation(1)
      carriage_return

      @device = nil
    end

    # Writes string to device
    # @param str String to write_raw_sequence
    # @param params Optional params => eg.: {:foreground => :red, :background => :white}
    def write_text(str, params = nil)
      temp_str = ""
      if params and params.kind_of? Hash
        temp_str += "\e[%d%dm" % [ANSI::Color::COLOR_MODES[:background], ANSI::Color::COLORS[params[:background]]] if ANSI::Color.color_mode_exists?(params)
        temp_str += "\e[%d%dm" % [ANSI::Color::COLOR_MODES[:foreground], ANSI::Color::COLORS[params[:foreground]]] if ANSI::Color.color_exists?(params)
      end
      temp_str += str

      write_raw_sequence(temp_str)

      @characters_on_current_row += str.length
      @characters_on_current_row = @characters_on_current_row % get_columns() if (@characters_on_current_row >= get_columns())
    end

    # Prints provided text to screen and fills the
    # rest of the line with empty space to prevent
    # overlapping text
    # @param str String to write_raw_sequence
    # @param params Optional params => eg.: {:foreground => :red, :background => :white}
    def write_line(str, params)
      empty_line_count = get_columns() - ((str.length + @characters_on_current_row) % get_columns())

      buffer_text = str

      empty_line = ""
      (0..empty_line_count).times do
        empty_line += " "

        buffer_text += empty_line

        write_text(buffer_text, params)
      end
    end

    # Writes string to buffer if buffered mode, else directly to device
    # @param command_str Commandsequence
    def write_raw_sequence(command_str)
      if buffered_write
        @buffer += command_str
      else
        write_to_device!(command_str)
      end
    end

    # Erase specified amount of rows starting from a specified row
    def erase_rows(start=0, rows=10)
      cursor_to_home
      (0..start).times do
        linebreak
      end

      (0..rows).times do
        columns = self.get_columns()
        empty_line = ""

        (0..columns).times do
          empty_line += " "
          write_raw_sequence(empty_line)
        end
      end
    end

    # Returns the amount of columns, depending on the current text size
    def get_columns
      if self.orientation == Screen.HORIZONTAL
        Screen.WIDTH / (@text_size * 6)
      else
        Screen.HEIGHT / (@text_size * 6)
      end
    end

    # Returns the amount of rows, depending on the current text size
    def get_rows
      if self.orientation == Screen.HORIZONTAL
        Screen.HEIGHT / (@text_size * 8)
      else
        Screen.WIDTH / (@text_size * 8)
      end
    end


    # VT100 FUNCTIONS
    # SIMPLE
    vt100_function :new_line, "\n"
    vt100_function :carriage_return, "\r"

    vt100_function :cursor_down, "\eD"
    vt100_function :cursor_down_row_one, "\eE"
    vt100_function :cursor_up, "\eM"
    vt100_function :reset_lcd, "\ec"
    vt100_function :erase_screen, "\e[2J"

    vt100_function :save_cursor_position, "\e[s"
    vt100_function :restore_cursor_position, "\e[u"

    # EXTENDED
    def keyboard_arrow_up(position)
      write_raw_sequence("\e[P%dA" % position)
    end

    def keyboard_arrow_down(position)
      write_raw_sequence("\e[P%dB" % position)
    end

    def keyboard_arrow_right(position)
      write_raw_sequence("\e[P%dC" % position)
    end

    def keyboard_arrow_left(position)
      write_raw_sequence("\e[P%dD" % position)
    end

    # Set cursor to x, y
    def set_cursor_position(x, y)
      write_raw_sequence("\e[P%d;P%dH" % [x, y])
    end

    # Set backlight PWM 0 - 255
    def set_backlight_brightness_pwm(pwm)
      write_raw_sequence("\e[P%dq" % pwm)
    end

    # Set backlight per Percentage 0 - 100%
    # Result will be rounded
    def set_backlight_brightness_percent(percent)
      write_raw_sequence("\e[P%dq" % (2.55 * percent))
    end

    # Set cursor to 0,0
    def cursor_to_home
      write_raw_sequence("\e[H")
      @characters_on_current_row = 0
    end

    # Set rotation of Display
    def set_rotation(rotation)
      write_raw_sequence("\e[%sr" % rotation)

      if rotation % 2 == 0
        @orientation = :vertical
      else
        @orientation = :horizontal
      end
    end

    # Set text size
    def set_text_size(size)
      write_raw_sequence("\e[%ss" % size)
      @text_size = size
    end

    # New line
    def linebreak
      new_line
      carriage_return
      @characters_on_current_row = 0
    end

    # Draw dot at x,y
    def draw_dot(x, y)
      write_raw_sequence("\e[P%d;P%dx" % [x, y])
    end

    # Reset screen full
    def reset_screen
      reset_lcd
      erase_screen
      cursor_to_home
    end

    # DEVICE FUNCTIONS
    # Flushes buffer => writes to device
    def flush!
      write_to_device!
    end

    # @param str Commandsequence (if nil buffer will be written)
    def write_to_device!(str)
      raise NoConnectionError, "You need to connect to device before transmitting data!" unless @device

      command_str = str ? str : buffer
      # If the command sequence is longer than 20 characters sending it all at once
      # will cause artifacts
      command_chunks = command_str.scan(/.{20}/)
      command_chunks.each do |chunk|
        @device.write("\006") # BEGIN
        ##### Length #####
        @device.write(chunk.length + 48)
        response = nil
        while response != '6'
          response = @device.read(1)
          sleep(0.1)
        end

        @device.write(chunk)
      end
    end

    private
    # Generic function definition for VT100 Functions
    def vt100_function(function, sequence)
      define_method(function) do
        write_raw_sequence(sequence)
      end
    end
  end
end
