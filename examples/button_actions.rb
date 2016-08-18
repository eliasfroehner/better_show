# You have to install the custom firmware from the sketchbook directory!

require 'better_show'

@ctx = BetterShow::ScreenContext.new(port: "/dev/ttyUSB1", buffered: false)
@ctx.erase_screen

loop {
  @ctx.on_button_0_pressed do
    @ctx.write_line "Button 0 pressed"
  end

  @ctx.on_button_0_released do
    @ctx.write_line "Button 0 released"
  end

  @ctx.on_button_1_pressed do
    @ctx.write_line "Button 1 pressed"
  end

  @ctx.on_button_1_released do
    @ctx.write_line "Button 1 released"
  end

  @ctx.on_button_2_pressed do
    @ctx.write_line "Button 2 pressed"
  end

  @ctx.on_button_2_released do
    @ctx.write_line "Button 2 released"
  end
}