require 'test/unit'
require '../lib/pietr'

class TestPrograms < Test::Unit::TestCase
  def test_simple
    alpha = Pietr.new 'programs/alphabet.png'
    assert_equal alpha.run, 'abcdefghijklmnopqrstuvwxyz'

    hw1 = Pietr.new 'programs/hello_world1.png'
    assert_equal hw1.run, 'Hello world!'

    hw2 = Pietr.new 'programs/hello_world2.png'
    assert_equal hw2.run, 'Hello world'

    hw3 = Pietr.new 'programs/hello_world3.png'
    assert_equal hw3.run, "Hello, world!\n"

    hw4 = Pietr.new 'programs/hello_world4.png'
    assert_equal hw4.run, "Hello, world!\n"

    tetris = Pietr.new 'programs/tetris.png'
    assert_equal tetris.run, 'Tetris'
  end

  def test_codel_size
    hw5 = Pietr.new 'programs/hello_world5.png', codel_size: 25
    assert_equal hw5.run, 'Hello world!'

    piet = Pietr.new 'programs/piet.png', codel_size: 16
    assert_equal piet.run, 'Piet'
  end

  def test_input
    fact4  = Pietr.new 'programs/factorial.png', input: '4'
    assert_equal fact4.run,  '24'

    fact6  = Pietr.new 'programs/factorial.png', input: '6'
    assert_equal fact6.run,  '720'

    fact20 = Pietr.new 'programs/factorial.png', input: '20'
    assert_equal fact20.run, '2432902008176640000'
  end

#  TODO: Prevent this taking so long.
#  def test_pi
#    pi = Pietr.new 'programs/pi.png'
#    assert_equal pi.run, '31405'
#  end
end
