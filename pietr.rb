require 'oily_png'

class Pietr
  COLORS = %w[000000
              ffc0c0 ffffc0 c0ffc0 c0ffff c0c0ff ffc0ff
              ff0000 ffff00 00ff00 00ffff 0000ff ff00ff
              c00000 c0c000 00c000 00c0c0 0000c0 c000c0]

  def initialize(filename, codel_size = 1)
    im = ChunkyPNG::Image.from_file filename
    cs = (codel_size ** 0.5).to_i
    @w, @h = im.width / cs, im.height / cs
    im.resample_nearest_neighbor! @w, @h unless cs == 1

    @stack = []
    @dp = @cc = 0 # direction pointer, codel chooser
    @cp = @rl = 0 # current position, restriction level
    @dirs = [1, @w, -1, -@w]
    @codels = im.pixels.map { |p| COLORS.index '%06x' % (p >> 8) }
  end

  def exit(origin)
    queue = [origin]
    @block = [origin]

    until queue.empty?
      pivot = queue.pop
      neighbors = @dirs.map { |n| pivot + n }.select do |n|
        n > 0 && n < @codels.size && @codels[n] == @codels[pivot]
      end
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

  def process(from, to)
    operation = (to % 6 - from % 6) % 6 * 3 + (to / 6 - from / 6) % 3
    case operation
      when  1 then @stack << @block.size # push
      when  2 then @stack.pop # pop
      when  3 then @stack << @stack.pop + @stack.pop # add
      when  4 then top = @stack.pop and @stack << @stack.pop - top # subtract
      when  5 then @stack << @stack.pop * @stack.pop # multiply
      when  6 then top = @stack.pop and @stack << @stack.pop / top # divide
      when  7 then top = @stack.pop and @stack << @stack.pop % top # modulo
      when  8 then @stack << @stack.pop == 0 ? 1 : 0 # not
      when  9 then @stack << (@stack.pop < @stack.pop ? 1 : 0) # greater
      when 10 then @dp = (@dp + @stack.pop) % 4 # pointer
      when 11 then @cc = @cc.succ % 2 if @stack.pop.odd? # switch
      when 12 then @stack << @stack[-1] # duplicate
      when 16 then print @stack.pop # out(number)
      when 17 then print @stack.pop.chr # out(char)
    end
  end

  def restrict
    (@rl += 1).odd? and @cc = @cc.succ % 2 or @dp = @dp.succ % 4
    Kernel.exit if @rl == 8
  end

  def run
    while 1
      exit = exit @cp
      goal = exit + @dirs[@dp]

      # Restrict flow on north and south boundaries as well as black codels.
      if @codels[goal] == 0 || goal < 0 || goal >= @codels.size
        restrict

      # Restrict flow at east and west boundaries.
      elsif @dp == 0 && goal % @w == 0 || @dp == 2 && goal % @w == @w - 1
        restrict

      else
        process @codels[@cp] - 1, @codels[goal] - 1
        # Update current position and reset restriction level.
        @cp, @rl = goal, 0
      end
    end
  end
end
