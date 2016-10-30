module Battleship

	Default_width = 10

	Ship_none = 0
	Ship_alive = 1
	Ship_dead = 2

	View_hidden = 0
	View_revealed = 1

	View_water = 0
	View_hit = 1
	View_miss = 2

	Missile_hit = 0
	Missile_miss = 1
	Missile_fail = 2 #something dumb happened, like you hit a sunken ship

	class Point
		attr_accessor :x, :y

		def initialize(x = 0, y = 0)
			@x = x
			@y = y
		end

		def equals(other)
			return false unless @x == other.x
			return false unless @y == other.y
			true
		end

		#taxicab distance (which works on a tiled board)
		#todo: make diagonals count for 1 instead of 2? idk

		def dist(x, y)
			(@x - x).abs + (@y - y).abs
		end

		def distPoint(other)
			dist(other.x, other.y)
		end

		def distCoord(c)
			dist(c[0], c[1])
		end

	end

	class Ship

		attr_reader :width, :height, x, y

		def initialize(width, height, x = 0, y = 0)
			@width = width
			@height = height
			@x = x
			@y = y
			@states = Array.new(@width) { Array.new(@height) {Ship_alive} }
			@life = width * height #number of hits left
		end

		def life()
			@life
		end

		def setPosition(x, y)
			@x = x
			@y = y
		end

		def containsAnyPoint(p)
			p.each do |pos|
				return true if containsPoint(pos)
			end
			false
		end

		def containsPoint(p)
			contains(p.x, p.y)
		end

		def containsAny(p)
			p.each do |pos|
				return true if contains(pos[0], pos[1])
			end
			false
		end

		def contains(x, y)
			return false if x < @x
			return false if y < @y
			return false if (x - @width) >= @x
			return false if (y - @height) >= @y
			true
		end

		def getState(x, y)
			if(contains(x, y))
				@states[x-@x][y-@x]
			end
			Ship_none

		def hit(x, y)
			if contains(x, y)
				if @states[x-@x][y-@y] == Ship_alive
					@states[x-@x][y-@y] = Ship_dead
					@life -= 1
					return Missile_hit
				end
				Missile_fail
			end
			Missile_miss
		end

		def getPointList()
			points = Array.new(@width * @height)
			c = 0
			(@x..(@x + @width - 1)).each do |i|
				(@y..(@y + @height - 1)).each do |j|
					points[c] = Point.new(i, j)
					c += 1
				end
			end
			points
		end

		def getCoordList()
			points = Array.new(@width * @height)
			c = 0
			(@x..(@x + @width - 1)).each do |i|
				(@y..(@y + @height - 1)).each do |j|
					points[c] = [i, j]
					c += 1
				end
			end
			points
		end

		def intersects(ship)
			containsAny(ship.getCoordList())
		end

		def distPoint(point)
			dist = -1
			getCoordList().each do |coord|
				d = point.distCoord(coord)
				dist = d if (dist < 0 || d < dist)
			end
			dist
		end

	#ship class
	end

	#ship builder

	def Battleship.makeShip(length, axis = -1, x = 0, y = 0)
		dx = axis == 0 ? length : 1
		dy = axis == 1 ? length : 1
		return Ship.new(dx, dy, x, y) #Battleship::Ship.new(dx, dy, x, y)
	end

	class Field

		attr_reader :width, :height
	
		def initialize(*args)
			if args.length == 1
				arg = args[0]
					if arg.is_a? Point
						@width = arg.x
						@height = arg.y
					else
						@width = @height = arg
					end
			else
				@width = args[0]
				@height = args[1]
			end
		end

		def containsPoint(p)
			contains(p.x, p.y)
		end

		def containsCoord(c)
			contains(c[0], c[1])
		end

		def contains(x, y)
			return false if (x < 0 || x >= @width)
			return false if (y < 0 || y >= @height)
			true
		end
	end

	class Board < Field
	
		def initialize(*args)
			super(args)
			#stores references to the ship at each coordinate
			@board_ships = Array.new(@width) { Array.new(@height) }
			#stores whether the board has been revealed at each coord
			@board_view = Array.new(@width) { Array.new(@height) { View_hidden } }
			#all dem ships
			@ships = Array.new
		end

		def addShip(ship)
			ship.getCoordList().each do |coord|
				@board_ships[coord[0]][coord[1]] = ship
			end
			@ships.push(ship)
		end

		def hitsLeft()
			sum = 0
			@ships.each do |ship|
				sum += ship.life
			end
			sum
		end

		###
		#old junk
		###

		def getView(x, y)
			return @board_view[x][y] if checkBounds(x, y)
			View_water
		end

		def getShip(x, y)
			return @board_ships[x][y] if checkBounds(x, y)
			Ship_none
		end

		def getNumShips()
			@ships.length
		end

		def addShip(x, y)
			if checkBounds(x, y)
				if @board_ships[x][y] != Ship_alive
					@board_ships[x][y] = Ship_alive
					@ships.push([x, y])
					true
				end
			end
			false
		end

		def addShips(x, dx, y, dy)
			#check bounds
			(x..(x + dx - 1)).each do |i|
				(y..(y + dx - 1)).each do |j|
					return false unless checkBounds(i, j)
					return false if @board_ships[i][j] == Ship_alive
				end
			end
			#add
			(x..(x + dx - 1)).each do |i|
				(y..(y + dx - 1)).each do |j|
					addShip(i, j)
				end
			end
			true
		end

		def missile(x, y)
			return false if not checkBounds(x, y)
			return false if @board_view[x][y] == View_hit
			if @board_ships[x][y] == Ship_alive
				@board_view[x][y] = View_hit
				@board_ships[x][y] = Ship_dead
				@ships.delete([x, y])
				true
			else
				@board_view[x][y] = View_miss
				false
			end
		end

		def to_s
			"Board[#{@width}x#{@height}]"
		end
	#board class
	end

	#command line utility methods

	def Battleship.printView(board)
		#column labels
		print " "
		(0..(board.width - 1)).each do |x|
			print getColumnLetter(x)
		end
		print "\n"
		#board
		(0..(board.height - 1)).each do |y|
			#row label
			print getRowLetter(y)
			(0..(board.width - 1)).each do |x|
				print getViewCharacter(board, x, y)
			end
			print "\n"
		end
	end

	def Battleship.getColumnLetter(index)
		(index + 65).chr
	end

	def Battleship.getColumnIndex(letter)
		letter.upcase.ord - 65
	end

	def Battleship.getRowLetter(index)
		index.to_s
	end

	def Battleship.getRowIndex(letter)
		letter.to_i
	end

	def Battleship.getViewCharacter(board, x, y)
		#the characters used to represent the states of the view array
		v = board.getView(x, y)
		return "x" if v == View_hit
		return "o" if v == View_miss
		"~"
	end

	def Battleship.cget(prompt = "")
		print prompt
		gets
	end

#module
end

#game processing
if __FILE__ == $0
	#run console
	puts "Starting battleship (Ruby)"

	#get input for size of board
	w = Battleship.cget("Enter width (or blank for default of #{Battleship::Default_width})): ").chomp.to_i
	w = Battleship::Default_width if w <= 0
	puts "Width: #{w}"

	h = Battleship.cget("Enter height (or blank for default of #{w})): ").chomp.to_i
	h = w if h <= 0
	puts "Height: #{h}"

	board = Battleship::Board.new(w, h)

	#custom ship count

	c = Battleship.cget("Enter number of ships (or blank for default of #{Battleship::Default_width}): ").chomp.to_i
	c = Battleship::Default_width if c <= 0
	puts "Number of ships: #{c}"

	#add the ships

	d = c
	safety = 0
	while d > 0 do
		x = rand(w)
		y = rand(h)
		axis = rand(2)
		dx = axis == 1 ? rand(w/2) + 1 : 1
		dy = axis == 0 ? rand(h/2) + 1 : 1
		if board.addShips(x, dx, y, dy)
			d -= 1
		else
			safety += 1
		end
		if safety > 10000 #10000 failures is a pretty reasonable number of attempts imo
			puts  "Failed to generate #{c} ships. Sorry :("
			break
		end
	end

	#start game

	puts "#{board.getNumShips()} hits left!"
	puts "Note: when launching missiles, specify column then row. Ex: 'A 4' or 'b 7'"
	moves = 0
	hits = 0
	while board.getNumShips() > 0 do

		#print the board (for the next move)
		puts
		Battleship.printView(board)

		#get input

		while true do
			line = Battleship.cget("Launch a missile! Coordinates: ").chomp()
			puts
			begin
				#parse
				line = line.split(" ", 2)
				if line.length < 2
					#need spaceee
					raise "This message doesn't matter"
				end
				column = Battleship.getColumnIndex(line[0])
				row = Battleship.getRowIndex(line[1])
				#act
				if board.missile(column, row)
					puts "It's a hit!"
					hits += 1
				else
					puts "You missed!"
				end
				#results
				moves += 1
				if board.getNumShips() > 0
					puts "#{board.getNumShips()} hits left!"
				end
				break
			rescue
				puts "Invalid coordinates specified"
			end
		end
		if board.getNumShips() <= 0
			#end game

			puts
			puts "You win!"
			print "It took you #{moves} move"
			print "s" if moves != 1
			puts "."
			puts "Accuracy: #{(Float(hits)/moves*100).round}%"
			puts
			Battleship.printView(board)
		end
	#game loop
	end
#console
end