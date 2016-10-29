module Testt
	Ta = 5
puts "Test 1"
if __FILE__ == $0
	puts "Test 2"
else
	puts "Test 3"
end
puts "Test 4"

def Testt.t(x)
	puts "ay#{x}"
end

Testt.t(1)
=begin
t 1
if __FILE__ == $0
	t 2
else
	t 3
end
t 4
=end

end

puts Testt::Ta

Testt.t 5
t 6