module BetterShow
  class Button
    BUTTON_0 = "0"
    BUTTON_1 = "1"
    BUTTON_2 = "2"

    PRESSED = "P"
    RELEASED = "R"

    BUTTON_NAME_MAP = {
        "0" => "button_0",
        "1" => "button_1",
        "2" => "button_2"
    }

    BUTTON_EVENT_NAME_MAP = {
        "P" => "pressed",
        "R" => "released"
    }
  end
end
