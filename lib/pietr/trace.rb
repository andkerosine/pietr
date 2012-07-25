class Pietr
  PRETTY = %w[0 69 77 45 47 27 75 64 76 36 31 19 66 48 36 20 22 18 49]

  def xy(index)
    "#{index % @w},#{index / @w}"
  end

  def colorized(str, color)
    "\e[38;5;#{PRETTY[color]}m#{str}\e[m"
  end

  def trace
    trace = '%12s' % "(#{xy @from}/#{'rdlu'[@pdp]}#{'lr'[@pcc]})"
    print colorized trace, @codels[@from]
    print ' -> '
    trace = '%-13s' % "(#{xy @to}/#{'rdlu'[@dp]}#{'lr'[@cc]})"
    print colorized trace, @codels[@to]
    print '%-4s' % OPERATIONS[@op]
    print '%-5s' % (@value.is_a?(String) ? @value.dump[1..-2] : @value)
    puts 'stack:' + @stack.reverse.map { |s| '%4s' % s }.join
  end
end
