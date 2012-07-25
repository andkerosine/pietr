require 'oily_png'
require_relative 'pietr/functions'

class Pietr
  COLORS = %w[000000
              ffc0c0 ffffc0 c0ffc0 c0ffff c0c0ff ffc0ff
              ff0000 ffff00 00ff00 00ffff 0000ff ff00ff
              c00000 c0c000 00c000 00c0c0 0000c0 c000c0]
  OPERATIONS = %w[nop pus pop add sub mul div mod not
                  grt ptr swc dup rol sin sic son soc]

  def initialize(filename, options = {})
    im = ChunkyPNG::Image.from_file filename
    cs = ((options[:codel_size] || 1) ** 0.5).to_i
    @w, @h = im.width / cs, im.height / cs
    im.resample_nearest_neighbor! @w, @h unless cs == 1
    @codels = im.pixels.map { |p| COLORS.index('%06x' % (p >> 8)) || 19 }

    @dp = @cc = 0 # direction pointer, codel chooser
    @cp = @rc = 0 # current position, restriction counter
    @dirs = [1, @w, -1, -@w]

    @stack, @output = [], ''
    @trace = options[:trace]
    $stdin = StringIO.new(options[:input], 'r') if options[:input]
  end

  def exit_codel
    arrow = @dp + @cc * 4
    @block.max_by do |b|
      max = []
      dir = arrow & 2 == 0 ? 1 : -1
      max << b.send(arrow.odd? ? :/ : :%, @w) * dir
      dir = (-5..-2) === -arrow ^ 2 ? 1 : -1
      max << b.send(arrow.odd? ? :% : :/, @w) * dir
    end
  end

  def block_tell(origin)
    queue = [origin]
    @block = [origin]

    until queue.empty?
      pivot = queue.pop
      neighbors = @dirs.map { |n| pivot + n }.select do |n|
        n > 0 && n < @codels.size && @codels[n] == @codels[pivot]
      end.reject { |n| (pivot - n).abs == 1 && pivot / @w != n / @w }

      neighbors -= @block
      @block.concat neighbors
      queue.concat neighbors
    end

    exit_codel
  end

  def execute(from, to)
    @from, @to = from, to
    from, to = @codels[from] - 1, @codels[to] - 1
    return if [from, to].include? 18

    @op = (to % 6 - from % 6) % 6 * 3 + (to / 6 - from / 6) % 3
    instance_exec &FUNCTIONS[@op] rescue nil

    trace if @trace
    @value, @pdp, @pcc = nil
  end

  def restrict
    (@rc += 1).odd? ? @cc = @cc.succ % 2 : @dp = @dp.succ % 4
  end

  def run
    while @rc < 8
      exit = block_tell @cp
      goal = exit + @dirs[@dp]
      break if goal == @from

      # Retain previous direction pointer and codel chooser, otherwise running
      # into a restricted codel would prevent accurate trace information.
      @pdp ||= @dp
      @pcc ||= @cc

      # Restrict flow at north and south boundaries and black codels.
      if @codels[goal] == 0 || goal < 0 || goal >= @codels.size
        restrict

      # Restrict flow at east and west boundaries.
      elsif @dp == 0 && goal % @w == 0 || @dp == 2 && goal % @w == @w - 1
        restrict

      else
        execute @cp, goal
        @cp, @rc = goal, 0
      end
    end

    @output
  end
end
