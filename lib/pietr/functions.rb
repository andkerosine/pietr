class Pietr
  FUNCTIONS = [nil,
    -> { @stack << @block.size },
    -> { @stack.pop },
    -> { @stack << @stack.pop + @stack.pop },
    -> { top = @stack.pop and @stack << @stack.pop - top },
    -> { @stack << @stack.pop * @stack.pop },
    -> { top = @stack.pop and @stack << @stack.pop / top },
    -> { top = @stack.pop and @stack << @stack.pop % top },
    -> { @stack << (@stack.pop == 0 ? 1 : 0) },
    -> { @stack << (@stack.pop < @stack.pop ? 1 : 0) },
    -> { @dp = (@dp + @stack.pop) % 4 },
    -> { top = @stack.pop and (@cc = @cc.succ % 2 if top && top.odd?) },
    -> { @stack << @stack[-1] },
    -> { @stack = [108, 3, 3, 108, 100, 10].reverse },
    -> { p 'in num' },
    -> { p 'in char' },
    -> { @stdout << @stack.pop.to_s },
    -> { @stdout << @stack.pop.chr }
  ]
end
