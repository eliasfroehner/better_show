# BetterShow

Library for the ODROID-SHOW/ODROID-SHOW2 written in Ruby

## Features
* All features of the ODROID-SHOW series are implemented
* Implemented fully in Ruby (no port_open binary needed)
* Supports stable native drawing of RGB 565 images
* Well tested

## Installation
Build it from source:

    $ rake build
    $ gem inst pkg/better_show-x.x.x.gem 

Add this line to your application's Gemfile:

```ruby
gem 'better_show'
```

And then execute:

    $ bundle

## Usage

```ruby
require 'better_show'

ctx = BetterShow::ScreenContext.new

ctx.erase_screen
ctx.set_rotation(BetterShow::Screen::ROTATION_NORTH)
ctx.set_background_color(:black)
ctx.set_foreground_color(:red)
ctx.write_line("Hello World!")
ctx.flush!
```
##### If you want use the button events, you have to compile the custom firmware located at the sketchbook directory.
##### For installing follow the [Guide](http://odroid.com/dokuwiki/doku.php?id=en:show_setting)

For other usage examples look at the examples directory.

## Supports

* [ODROID-SHOW](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G139781817221)
* [ODROID-SHOW2](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G141743018597)

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## State
* In progress

## Credits

[Matoking/SHOWtime](https://github.com/Matoking/SHOWtime)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/api-walker/better_show.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

