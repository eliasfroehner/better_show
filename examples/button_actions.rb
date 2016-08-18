# You have to install the custom firmware from the sketchbook directory!

require 'better_show'

ctx = BetterShow::ScreenContext.new(port: "/dev/ttyUSB0", buffered: false)
ctx.erase_screen
ctx.set_rotation(BetterShow::Screen::ROTATION_NORTH)

loop {
  ctx.on_button_0_pressed do
    ctx.write_line "Button 0 pressed"
  end

  ctx.on_button_0_released do
    ctx.write_line "Button 0 released"
  end

  ctx.on_button_1_pressed do
    ctx.write_line "Button 1 pressed"
  end

  ctx.on_button_1_released do
    ctx.write_line "Button 1 released"
  end

  ctx.on_button_2_pressed do
    ctx.write_line "Button 2 pressed"
  end

  ctx.on_button_2_released do
    ctx.write_line "Button 2 released"
  end
}