require 'better_show'

@ctx = BetterShow::ScreenContext.new

@ctx.erase_screen
@ctx.set_rotation(BetterShow::Screen::ROTATION_NORTH)
@ctx.set_background_color(:white)
@ctx.set_foreground_color(:red)
@ctx.write_line("Line 1")
@ctx.linebreak
@ctx.write_line("Line 2")
@ctx.linebreak
@ctx.write_line("Line 3")
@ctx.flush!