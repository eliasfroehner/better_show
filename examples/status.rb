require 'better_show'
require 'sys/uname'
require 'sys/filesystem'
require 'net/ping'
require 'usagewatch'
include Sys

GIGABYTE = 1024 * 1024 * 1024
REFRESH_TIME = 1 #s

@mutex = nil

def main
  # General variables
  mount_path_1 = "/"
  mount_path_2 = "/home"
  mount_path_3 = "/bin"

  mount_path_1 = $1 if $1
  mount_path_2 = $2 if $2
  mount_path_3 = $3 if $3

  mount_path = mount_path_1

  # Initialize screen
  ctx = BetterShow::ScreenContext.new
  ctx.erase_screen

  ctx.on_button_0_pressed do
    mount_path = mount_path_1
    draw!(ctx, mount_path, true)
  end

  ctx.on_button_1_pressed do
    mount_path = mount_path_2
    draw!(ctx, mount_path, true)
  end

  ctx.on_button_2_pressed do
    mount_path = mount_path_3
    draw!(ctx, mount_path, true)
  end

  loop {
    draw!(ctx, mount_path)
    sleep(REFRESH_TIME)
  }
end

def draw!(ctx, mount_path, redraw = false)
  # Wait for mutex to be unlocked
  while @mutex;end

  # Set mutex
  @mutex = true

  if redraw
    ctx.erase_screen
  else
    ctx.cursor_to_home
  end

  ctx.set_foreground_color(:magenta)
  # Time
  ctx.write_line(Time.now.strftime("%c"))

  # OS info
  print_os_info(ctx, "Host: ", Uname.nodename)
  print_os_info(ctx, "OSName: ", Uname.sysname)
  print_os_info(ctx, "Version: ", Uname.release)
  print_os_info(ctx, "Machine: ", Uname.machine)

  # Resources
  ctx.linebreak
  print_resources(ctx)

  # Filesystem
  stat = Filesystem.stat(mount_path)
  diskspace = ((stat.blocks * stat.block_size).to_f / GIGABYTE).round(2)
  diskspace_free = ((stat.blocks_available * stat.block_size).to_f / GIGABYTE).round(2)
  diskspace_used = (diskspace - diskspace_free).round(2)

  # OS info
  ctx.linebreak
  print_os_info(ctx, "Mountpath: ", mount_path)
  print_info(ctx, "Disksize:  ", "#{diskspace} G", :yellow, :green)
  print_info(ctx, "Used:  ", "#{diskspace_used} G", :red, :green)
  print_info(ctx, "Free:  ", "#{diskspace_free} G", :blue, :green)

  ctx.flush!

  # Unlock mutex
  @mutex = nil
end

# HELPER
def print_resources(ctx)
  cpu_usage = Usagewatch.uw_cpuused
  # Mem usage don't works with Usagewatch
  # get mem usage via free binary
  mem_stats = IO.popen(["free", "-m"]).read.split("\n")[1].split("        ")
  mem_max = (mem_stats[1].to_f / 1024)
  mem_used = (mem_stats[2].to_f / 1024)
  mem_usage = ((mem_used / mem_max) * 100).round(2)

  cpu_color = get_resource_usage_color(cpu_usage)
  mem_color = get_resource_usage_color(mem_usage)

  print_info(ctx, "CPU: ", "#{cpu_usage}%", :white, cpu_color)
  print_info(ctx, "Memory: ", "#{mem_usage}% (#{mem_used.round(1)}G/#{mem_max.round(1)}G)", :white, mem_color)

  # Internet access
  internet_check = Net::Ping::HTTP.new('http://www.google.com')
  internet_state = internet_check.ping?
  print_info(ctx, "Internet access: ", internet_state ? "yes" : "no", :white, internet_state ? :green : :red)
end

def get_resource_usage_color(usage)
  case usage
    when 0...20
      :green
    when 20...50
      :yellow
    when 50...70
      :magenta
    else
      :red
  end
end

def print_os_info(ctx, type, value)
  print_info(ctx, type, value, :white, :cyan)
end

def print_info(ctx, type, value, type_color, value_color)
  ctx.set_foreground_color(type_color)
  ctx.write_text(type)
  ctx.set_foreground_color(value_color)
  ctx.write_line(value)
end

if __FILE__ == $0
  main
end
