require 'test_helper'
require 'digest/md5'

class BetterShowTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BetterShow::VERSION
  end

  def test_initialize
    @ctx = BetterShow::ScreenContext.new(port: "/dev/ttyUSB1", buffered: false)
    assert_equal "/dev/ttyUSB1", @ctx.device_port
    assert_equal false, @ctx.buffered_write
    assert_equal "", @ctx.virtual_device
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

    assert_equal 301, @ctx.virtual_device.size
  end

  def test_write_text
    @ctx = BetterShow::ScreenContext.new
    @ctx.write_text("Hello World")

    assert_equal "Hello World", @ctx.virtual_device
  end

  def test_write_line
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_foreground_color(:red)
    @ctx.set_background_color(:white)
    @ctx.write_line("Hello World")

    assert_equal 36, @ctx.virtual_device.size # 26 Columns + 10 bytes color codes
  end

  def test_set_foreground_color
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_foreground_color(:red)

    assert_equal "\e[31m", @ctx.virtual_device
  end

  def test_set_background_color
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_background_color(:white)

    assert_equal "\e[47m", @ctx.virtual_device
  end

  def test_invalid_color
    @ctx = BetterShow::ScreenContext.new

    assert_raises BetterShow::ScreenContext::ColorError do
      @ctx.set_background_color(:wrong_color)
    end
  end

  def test_write_raw_sequence
    @ctx = BetterShow::ScreenContext.new
    @ctx.write_raw_sequence("\ecHello World")

    assert_equal "\ecHello World", @ctx.virtual_device
  end

  def test_new_line
    @ctx = BetterShow::ScreenContext.new
    @ctx.new_line

    assert_equal "\n", @ctx.virtual_device
  end

  def test_carriage_return
    @ctx = BetterShow::ScreenContext.new
    @ctx.carriage_return

    assert_equal "\r", @ctx.virtual_device
  end

  def test_cursor_down
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_down

    assert_equal "\eD", @ctx.virtual_device
  end

  def test_cursor_down_row_one
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_down_row_one

    assert_equal "\eE", @ctx.virtual_device
  end

  def test_cursor_up
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_up

    assert_equal "\eM", @ctx.virtual_device
  end

  def test_reset_lcd
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_lcd

    assert_equal "\ec", @ctx.virtual_device
  end

  def test_erase_screen
    @ctx = BetterShow::ScreenContext.new
    @ctx.erase_screen

    assert_equal "\e[2J", @ctx.virtual_device
  end

  def test_save_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.save_cursor_position

    assert_equal "\e[s", @ctx.virtual_device
  end

  def test_restore_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.restore_cursor_position

    assert_equal "\e[u", @ctx.virtual_device
  end

  def test_restore_cursor_to_home
    @ctx = BetterShow::ScreenContext.new
    @ctx.cursor_to_home

    assert_equal "\e[H\e[37m\e[40m", @ctx.virtual_device
  end

  def test_keyboard_arrow_up
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_up(1)

    assert_equal "\e[1A", @ctx.virtual_device
  end

  def test_keyboard_arrow_down
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_down(1)

    assert_equal "\e[1B", @ctx.virtual_device
  end

  def test_keyboard_arrow_right
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_right(1)

    assert_equal "\e[1C", @ctx.virtual_device
  end

  def test_keyboard_arrow_left
    @ctx = BetterShow::ScreenContext.new
    @ctx.keyboard_arrow_left(1)

    assert_equal "\e[1D", @ctx.virtual_device
  end

  def test_set_cursor_position
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_cursor_position(1, 2)

    assert_equal "\e[1;P2H", @ctx.virtual_device
  end

  def test_set_backlight_brightness_pwm
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_backlight_brightness_pwm(240)

    assert_equal "\e[240q", @ctx.virtual_device
  end

  def test_set_backlight_brightness_percent
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_backlight_brightness_percent(10)

    assert_equal "\e[25q", @ctx.virtual_device
  end

  def test_set_rotation
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_rotation(1)

    assert_equal "\e[1r", @ctx.virtual_device
  end

  def test_set_text_size
    @ctx = BetterShow::ScreenContext.new
    @ctx.set_text_size(4)

    assert_equal "\e[4s", @ctx.virtual_device
  end

  def test_linebreak
    @ctx = BetterShow::ScreenContext.new
    @ctx.linebreak

    assert_equal "\r\n", @ctx.virtual_device
  end

  def test_draw_dot
    @ctx = BetterShow::ScreenContext.new
    @ctx.draw_dot(1, 2)

    assert_equal "\e[1;P2x", @ctx.virtual_device
  end

  def test_draw_image
    @ctx = BetterShow::ScreenContext.new
    @ctx.draw_image("test/files/penguin.raw")

    assert_equal "e85e78d3a4e8ea4a7b47399955a39b64", Digest::MD5.hexdigest(@ctx.virtual_device) #header + data
  end

  def test_reset_screen
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_screen

    assert_equal "\ec\e[2J\e[H\e[37m\e[40m", @ctx.virtual_device
  end

  def test_clear_buffer
    @ctx = BetterShow::ScreenContext.new
    @ctx.reset_screen
    @ctx.clear_buffer!

    assert_equal "", @ctx.virtual_device
  end
end
