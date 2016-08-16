module BetterShow
  module ANSI
    class Color
      # Constants
      COLORS = {
          :black => 0,
          :red => 1,
          :green => 2,
          :yellow => 3,
          :blue => 4,
          :magenta => 5,
          :cyan => 6,
          :white => 7,
          :default => 9,
      }

      COLOR_MODES = {
          :foreground => 3,
          :background => 4,
      }

      # Checks if params contains :foreground and valid color
      def self.color_exists?(params)
        if params[:foreground]
          COLORS[params[:foreground]]
        else
          false
        end
      end

      # Checks if params contains :background and valid colormode
      def self.color_mode_exists?(params)
        if params[:background]
          COLORS[params[:background]]
        else
          false
        end
      end
    end
  end
end