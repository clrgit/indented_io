#!/usr/bin/env ruby

exec("bundle exec #$0 '#{ARGV.join("' '")}'") if !ENV.key?('BUNDLE_BIN_PATH')

RUNS = 1_000_000

saved_stdout = $stdout
$stdout = File.open("/dev/null", "w")

def timeit(&block)
  t0 = Time.now
  RUNS.times {
    yield
  }
  t1 = Time.now
  (1000 * (t1 - t0)).round(0)
end

def report(title, wo_indent, w_indent)
  times = (w_indent / wo_indent).round(1)
  if times < 1.1
    slower = "same speed"
  else
    slower = "#{times} times slower"
  end

  puts title
  indent {
    puts "w/o indented_io: #{wo_indent}ms"
    puts "w/indented_io  : #{w_indent}ms (#{slower})"
  }
end

# No indent
# 
flat_output_wo_indent = timeit { puts "Not indented" }

require 'indented_io'

flat_output_w_indent = timeit { puts "Not indented" }

# Indented one level
#
static_wo_indent = timeit { puts "  Indented" }

static_w_indent = nil
indent {
  static_w_indent = timeit { puts "Indented" }
}

# Indented by a dynamic string
#
indent = "  "
dynamic_wo_indent = timeit {
  puts "#{indent}Indented"
}

dynamic_w_indent = nil
indent("  ") {
  dynamic_w_indent = timeit { puts "Indented" }
}

# Recursive indentation
#
def recur_wo_indent(level, indent)
  puts "#{indent}Indented"
  if level > 0
    recur_wo_indent(level - 1, "#{indent}  ")
  end
end

def recur_w_indent(level)
  puts "Indented"
  if level > 0
    indent { recur_w_indent(level - 1) }
  end
end

recursive_wo_indent = timeit { recur_wo_indent(2, "  ") }
recursive_w_indent = timeit { recur_w_indent(2) }

$stdout = saved_stdout

puts "Performance with #{RUNS} runs"
puts

report "Flat output", flat_output_wo_indent, flat_output_w_indent
report "Static indent", static_wo_indent, static_w_indent
report "Dynamic indent", dynamic_wo_indent, dynamic_w_indent
report "Recursive indent", recursive_wo_indent, recursive_w_indent


















