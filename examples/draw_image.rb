require 'better_show'

ctx = BetterShow::ScreenContext.new
ctx.erase_rows(0, ctx.get_rows)
ctx.set_rotation(BetterShow::Screen::ROTATION_WEST)
ctx.draw_image("../test/files/penguin.raw")
ctx.flush!