module Battleship

	Default_width = 10

	Ship_none = 0
	Ship_alive = 1
	Ship_dead = 2

	View_water = 0
	View_hit = 1
	View_miss = 2

	class Board

		attr_accessor :width :height
	
		# Create the object
		def initialize(*args)
			if args.length == 1
				@width = @height = args[0]
			else
				@width = args[0]
				@height = args[1]
			end
			@board_ships = Array.new(@width) { Array.new(@height) }
			@board_view = Array.new(@width) { Array.new(@height) }
			@ships = Array.new
		end

		def checkBounds(x, y)
			return false if (x < 0 || x >= @width)
			return false if (y < 0 || y >= @height)
			true
		end

		def getView(x, y)
			return @board_view[x][y] if checkBounds(x, y)
			View_water
		end

		def getShip(x, y)
			return @board_ships[x][y] if checkBounds(x, y)
			Ship_none
		end

		def getNumShips()
			ships.length
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

		def addShips(x, y)
			#TODO
			#too lazy rn
		end

=begin

    def addShips(self, x, dx, y, dy):
        #when you have to iterate twice because you have to check first
        for i in range(x, x + dx):
            for j in range(y, y + dy):
                if (not self.checkBounds(i, j)) or self.board_ships[i][j] == SHIP_ALIVE:
                    return False
        #ugh
        for i in range(x, x + dx):
            for j in range(y, y + dy):
                self.addShip(i, j)
        return True

=end

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

	end #Board class

	#command line utility methods

	def printView(board)
		#column labels
		print " "
		(0..(board.width - 1).each do |x|
			print getColumnLetter(x)
		end
		print "\n"
		#board
		(0..(board.height - 1).each do |y|
			print getColumnLetter(y)
			(0..(board.width - 1).each do |x|
				print getViewCharacter(board, x, y)
			end
			print "\n"
		end
	end

	def getColumnLetter(index)
		chr(index)
	end

	def getColumnIndex(letter)
		letter.ord
	end

	def getRowLetter(index)
		index.to_s
	end

	def getRowIndex(letter)
		letter.to_i
	end

	def getViewCharacter(board, x, y)
		#the characters used to represent the states of the view array
		v = board.getView(x, y)
		return "x" if v == View_hit
		return "o" if v == View_miss
		"~"
	end

	#game processing

	if __FILE__ == $0
		puts "Starting battleship (Ruby)"
		board = Board.new(10)
		puts board
	end #game loop and such

end #module