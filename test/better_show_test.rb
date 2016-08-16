require 'test_helper'

class BetterShowTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BetterShow::VERSION
  end

  def test_initialize
    @ctx = BetterShow::ScreenContext.new("/dev/ttyUSB1", false)
    assert_equal "/dev/ttyUSB1", @ctx.device_port
    assert_equal false, @ctx.buffered_write
    assert_equal "", @ctx.buffer
  end

  def test_write_to_disconnected_device
    @ctx = BetterShow::ScreenContext.new
    @ctx.carriage_return
    assert_raises BetterShow::ScreenContext::NoConnectionError do
      @ctx.flush!
    end
  end

  def test_get_columns
    @ctx = BetterShow::ScreenContext.new

    assert_equal 26, @ctx.get_columns
  end

  def test_get_rows
    @ctx = BetterShow::ScreenContext.new

    assert_equal 15, @ctx.get_rows
  end

  def test_erase_rows
    @ctx = BetterShow::ScreenContext.new
    @ctx.erase_rows

    assert_equal 291, @ctx.buffer.size
  end

  def test_write_text
    @ctx = BetterShow::ScreenContext.new
    @ctx.write_text("Hello World", :foreground => :red, :background => :white)
    assert_equal "\e[47m\e[31mHello World", @ctx.buffer

    @ctx.clear_buffer!
    @ctx.write_text("Hello World", :foreground => :red)
    assert_equal "\e[31mHello World", @ctx.buffer

    @ctx.clear_buffer!
    @ctx.write_text("Hello World")
    assert_equal "Hello World", @ctx.buffer
  end

  def test_write_line
    @ctx = BetterShow::ScreenContext.new
    @ctx.write_line("Hello World", :foreground => :red, :background => :white)

    assert_equal 36, @ctx.buffer.size # 26 Columns + 10 bytes color codes
  end

  def test_write_raw_sequence
    @ctx = BetterShow::ScreenContext.new
    @ctx.write_raw_sequence("\ecHello World")

    assert_equal "\ecHello World", @ctx.buffer
  end

  def test_new_line
    @ctx = BetterShow::ScreenContext.new
    @ctx.new_line

    assert_equal "\n", @ctx.buffer
  end

  def test_carriage_return
    @ctx = BetterShow::ScreenContext.new
    @ctx.carriage_return

    assert_equal "\r", @ctx.buffer
  end

  def test_cursor_down
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_down

    assert_equal "\eD", @ctx.buffer
  end

  def test_cursor_down_row_one
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_down_row_one

    assert_equal "\eE", @ctx.buffer
  end

  def test_cursor_up
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_up

    assert_equal "\eM", @ctx.buffer
  end

  def test_reset_lcd
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_lcd

    assert_equal "\ec", @ctx.buffer
  end

  def test_erase_screen
    @ctx = BetterShow::ScreenContext.new
    @ctx.erase_screen

    assert_equal "\e[2J", @ctx.buffer
  end

  def test_save_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.save_cursor_position

    assert_equal "\e[s", @ctx.buffer
  end

  def test_restore_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.restore_cursor_position

    assert_equal "\e[u", @ctx.buffer
  end

  def test_restore_cursor_to_home
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_to_home

    assert_equal "\e[H", @ctx.buffer
  end

  def test_keyboard_arrow_up
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_up(1)

    assert_equal "\e[1A", @ctx.buffer
  end

  def test_keyboard_arrow_down
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_down(1)

    assert_equal "\e[1B", @ctx.buffer
  end

  def test_keyboard_arrow_right
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_right(1)

    assert_equal "\e[1C", @ctx.buffer
  end

  def test_keyboard_arrow_left
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_left(1)

    assert_equal "\e[1D", @ctx.buffer
  end

  def test_set_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_cursor_position(1, 2)

    assert_equal "\e[1;P2H", @ctx.buffer
  end

  def test_set_backlight_brightness_pwm
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_backlight_brightness_pwm(240)

    assert_equal "\e[240q", @ctx.buffer
  end

  def test_set_backlight_brightness_percent
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_backlight_brightness_percent(10)

    assert_equal "\e[25q", @ctx.buffer
  end

  def test_set_rotation
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_rotation(1)

    assert_equal "\e[1r", @ctx.buffer
  end

  def test_set_text_size
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_text_size(4)

    assert_equal "\e[4s", @ctx.buffer
  end

  def test_linebreak
    @ctx = BetterShow::ScreenContext.new
    @ctx.linebreak

    assert_equal "\r\n", @ctx.buffer
  end

  def test_draw_dot
    @ctx = BetterShow::ScreenContext.new
    @ctx.draw_dot(1, 2)

    assert_equal "\e[1;P2x", @ctx.buffer
  end

  def test_reset_screen
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_screen

    assert_equal "\ec\e[2J\e[H", @ctx.buffer
  end

  def test_clear_buffer
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_screen
    @ctx.clear_buffer!

    assert_equal "", @ctx.buffer
  end
end
