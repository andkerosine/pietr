require 'oily_png'
require_relative 'pietr/functions'

class Pietr
  COLORS = %w[000000
              ffc0c0 ffffc0 c0ffc0 c0ffff c0c0ff ffc0ff
              ff0000 ffff00 00ff00 00ffff 0000ff ff00ff
              c00000 c0c000 00c000 00c0c0 0000c0 c000c0]
  OPERATIONS = %w[nop pus pop add sub mul div mod not
                  grt ptr swc dup rol inn inc otn otc]

  def initialize(filename, options)
    im = ChunkyPNG::Image.from_file filename
    cs = (options[:codel_size] ** 0.5).to_i
    @w, @h = im.width / cs, im.height / cs
    im.resample_nearest_neighbor! @w, @h unless cs == 1
    @codels = im.pixels.map { |p| COLORS.index '%06x' % (p >> 8) }

    @dp = @cc = 0 # direction pointer, codel chooser
    @cp = @rl = 0 # current position, restriction level
    @dirs = [1, @w, -1, -@w]
    @step = -1
    @stdout, @stack, @trace = '', [], options[:trace]
  end

  def exit(origin)
    queue = [origin]
    @block = [origin]

    until queue.empty?
      pivot = queue.pop
      neighbors = @dirs.map { |n| pivot + n }.select do |n|
        n > 0 && n < @codels.size && @codels[n] == @codels[pivot]
      end.reject { |n| (pivot - n).abs == 1 && pivot / @w != n / @w}
      neighbors -= @block
      @block.concat neighbors
      queue.concat neighbors
    end

    # I have no idea what I am doing.
    arrow = @dp + @cc * 4
    @block.max_by do |b|
      max = []
      dir = arrow & 2 == 0 ? 1 : -1
      max << b.send(arrow.odd? ? :/ : :%, @w) * dir
      dir = (-5..-2) === -arrow ^ 2 ? 1 : -1
      max << b.send(arrow.odd? ? :% : :/, @w) * dir
    end
  end

  def xy(pos)
    [pos % @w, pos / @w]
  end

  def process(from, to)
    puts "step #{@step += 1}\ndp: #{'rdlu'[@dp]}, cc: #{'lr'[@cc]}, from: #{from} - #{xy from}, to: #{to} - #{xy to}" if @trace
    from = @codels[from] - 1
    to = @codels[to] - 1
    op = (to % 6 - from % 6) % 6 * 3 + (to / 6 - from / 6) % 3
    instance_exec &FUNCTIONS[op] rescue nil
  end

  def restrict
    (@rl += 1).odd? and @cc = @cc.succ % 2 or @dp = @dp.succ % 4
  end

  def run
    while @rl < 8
      exit = exit @cp
      goal = exit + @dirs[@dp]

      # Restrict flow at north and south boundaries and black codels.
      if @codels[goal] == 0 || goal < 0 || goal >= @codels.size
        restrict

      # Restrict flow at east and west boundaries.
      elsif @dp == 0 && goal % @w == 0 || @dp == 2 && goal % @w == @w - 1
        restrict

      else
        process @cp, goal
        @cp, @rl = goal, 0 # Update current position, reset restriction level.
      end
    end

    print @stdout
  end
end
