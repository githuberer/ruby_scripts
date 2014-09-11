#!/usr/bin/env ruby



class Point
  def initialize
    @x, @y, @d = 0, 0, 1
  end

  private
  def turning(direction)
    if direction == "l"
      if @d == 1
        @d = 4
      else
        @d -= 1
      end
    elsif direction == "r"
      if @d == 4
        @d = 1
      else
        @d += 1
      end
    end
  end
  def move(n)
    case @d
    when 1 then @x += n
    when 3 then @x -= n
    end
    case @d
    when 4 then @y += n
    when 2 then @y -= n
    end
  end

  public
  def go(action) # action = [ move, diction ]
    turning(action[1]) if action.size == 2
    move(action[0])
    result =<<-EOF
    坐标:  (#{@x}, #{@y})
    方向:  #{@d}
    EOF
    #dirction:   #{@direction[@coord[2]]}
  end
end


p = Point.new
input = []


puts <<-EOF

0,  'Ctrl + c'或者输入'q'则退出程序。
1,  输入一个数字，然后空格，另外输出一个字母，字母可以为'l'或者'r'或者为空。
2,  数字代表移动格数，字母代表改变的方向，'l'代表左转90度，'r'反之。
3,  例如，输入'5 l'代表相左转90度，然后移动5格，然后计算出坐标位置。
4,  1, 2, 3, 4分别代表x, -y, -x, y四个方向，如下图：

              y 4
              ^
              |
              |
              |
 3            |
-x------------@->------------>x 1 (default direction)
              |
              |
              |
              |
              |
             -y 2

EOF


until input[0] == 'q' do
  puts "\n\n等待输入："
    input = gets().split("\s")
    input[0] = input[0].to_i
    puts p.go(input)
end


