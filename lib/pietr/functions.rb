class Pietr
  FUNCTIONS = [nil,
    -> { @stack << @value = @block.size },                     # pus
    -> { @stack.pop },                                         # pop
    -> { @stack << @stack.pop(2).reduce(:+) },                 # add
    -> { @stack << @stack.pop(2).reduce(:-) },                 # sub
    -> { @stack << @stack.pop(2).reduce(:*) },                 # mul
    -> { @stack << @stack.pop(2).reduce(:/) },                 # div
    -> { @stack << @stack.pop(2).reduce(:%) },                 # mod
    -> { @stack << (@stack.pop == 0 ? 1 : 0) },                # not
    -> { @stack << (@stack.pop < @stack.pop ? 1 : 0) },        # grt
    -> { @dp = (@dp + @stack.pop) % 4 },                       # ptr
    -> { @cc = @cc.succ % 2 if @stack.pop.to_i.odd? },         # swc
    -> { @stack << @stack[-1] },                               # dup
    -> { depth, by = @stack.pop 2
         @stack[-depth..-1] = @stack[-depth..-1].rotate -by }, # rol
    -> { @stack << $stdin.gets.to_i },                         # sin
    -> { @stack << $stdin.getc },                              # sic
    -> { @output << @value = @stack.pop.to_s },                # son
    -> { @output << @value = '' << @stack.pop.chr }            # soc
  ]
end
