#rubocop : disable all

module Illegal_move
  def move_put_piece_chess?(board_obj,destinationX,destinationY)
      in_chess = false
      piece = board_obj.find_piece_at(@position[0],@position[1])
      old_pos = piece.position
      piece.position = [destinationX,destinationY]
      in_chess == true if board_obj.chess?(piece.color_binary)
      piece.position = old_pos
      return in_chess
  end
end

module QueenRookBishopTakeAndMove
  include Illegal_move
    def move?(board_obj, destinationX, destinationY)
      found = false
      mooves = self.class::MOVE_SET
      x, y = @position[0], @position[1]
      mooves.each do |move|
        loop do
          x += move[0]
          y += move[1]
          break if on_board?(x, y) == false
          break if board_obj.find_piece_at(x, y) != nil
          found = true if x == destinationX && y == destinationY
        end
        x, y = @position[0], @position[1]
      end
      return found
    end
  
    def take?(board_obj, destinationX, destinationY)
        found = false
        mooves = self.class::MOVE_SET
        x, y = @position[0], @position[1]
        mooves.each do |move|
          loop do
            x += move[0]
            y += move[1]
            break if on_board?(x, y) == false
            piece = board_obj.find_piece_at(x, y)
            if piece != nil
              if piece.color != @color
                found = true if (x == destinationX && y == destinationY) && (piece.color != @color)
                break
              else
                break
              end
            end
          end
          x, y = @position[0], @position[1]
        end
        return found
      end
      
end


  
  

class Piece
    include Illegal_move
    
    attr_accessor :symbol, :arr_symbol, :color, :position, :SYMBOL_CHOICES, :color_binary, :display_color, :instance_class_name, :moved, :storage_turn
  
    COLOR0 = "white"
    COLOR1 = "black"

    DISPLAY_COLOR0 = "red"
    DISPLAY_COLOR1 = "black"
    
  
    def self.included(base)
      base.const_set(:SYMBOL_CHOICES, base::SYMBOL_CHOICES)
    end
  
    def initialize(pos,color_binary)
        @color_binary = color_binary
        @color = set_color(color_binary)
        @position = [pos[0],pos[1]]
        @moved = false
        utilities
        @symbol = set_symbol(color_binary) # move this line to the end
        @display_color = set_display_color(color_binary)
        @instance_class_name = set_instance_class_name
        @storage_turn = 0
        
        
    end

    def move!(destination)
      @position = destination

    end

    def set_instance_class_name
        @instance_class_name = self.class.name
    end
  
    def set_symbol(color_binary)  #useless - using the full symbol for more readability
        symbol_choices = self.class.const_get(:SYMBOL_CHOICES)
        return @symbol = symbol_choices[1] if color_binary == 0
        return @symbol = symbol_choices[1] if color_binary == 1
    end
  
    def set_color(color_binary)
        return @color = COLOR0 if color_binary == 0
        return @color = COLOR1 if color_binary == 1
    end

    def set_display_color(color_binary)
        return @display_color = DISPLAY_COLOR0 if color_binary == 0
        return @display_color = DISPLAY_COLOR1 if color_binary == 1
    end
  
    def utilities
        return
    end
  
    def generate_coor_array
        (0...8).to_a.product((0...8).to_a)
    end
  
    def on_board?(x, y)
        (0..7).include?(x) && (0..7).include?(y)
    end

    def introduction
        puts "i'm a #{@color} #{self.class.name} in #{@position}"
    end

    def quick_info
        puts "#{@color} / #{self.class.name} / #{@position}"
    end

    def display_possible_move_and_take(board_obj)
        all_moves = generate_coor_array
        move_arr = []
        take_arr = []
        all_moves.each do |move| 
            move_arr.push(move) if move?(board_obj,move[0],move[1])
            take_arr.push(move) if take?(board_obj,move[0],move[1])
        end
        #introduction()

        letter_move_arr = move_arr.map{|move| move = board_obj.coordinates_to_position(move)}
        letter_take_arr = take_arr.map{|move| move = board_obj.coordinates_to_position(move)}
        
        #p "Possible move arr #{move_arr} #{letter_move_arr}"
        #p "Possible take arr #{take_arr} #{letter_take_arr}"
    
    end

    def possible_moves(board_obj)
      all_moves = generate_coor_array
      all_moves.delete([@position])
      move_arr = []
     
      all_moves.each do |move| 
          move_arr.push(move) if move?(board_obj,move[0],move[1]) 
      end
      return move_arr
    end

    def possible_takes(board_obj)
      all_moves = generate_coor_array
      all_moves.delete([@position])
      take_arr = []
     
      all_moves.each do |move| 
          take_arr.push(move) if take?(board_obj,move[0],move[1]) 
      end
      return take_arr
    end

    def possible_moves_and_take(board_obj)
      move_arr = possible_moves(board_obj)
      take_arr = possible_takes(board_obj)
      return move_arr +take_arr
      
    end

    def promotion(board_obj)
      # Check if the Pawn has reached the opposite end of the board
      if @instance_class_name == "Pawn" && ((@color_binary == 0 && @position[1] == 7) || (@color_binary == 1 && @position[1] == 0))
        # Remove the Pawn from the board
        board_obj.pieces_arr.delete(self)
    
        # Present the user with a list of choices for the piece to promote to
        puts "Your Pawn is promoted, which piece would you like to create?"
        puts "1. Queen"
        puts "2. Rook"
        puts "3. Bishop"
        puts "4. Knight"
    
        # Get the user's choice and create the chosen piece
        loop do
          print "Enter a number (1-4): "
          user_input = gets.chomp.to_i
          if user_input.between?(1,4)
            # Create the chosen piece and add it to the board
            piece = case user_input
                    when 1 then Queen.new(@position, @color_binary)
                    when 2 then Rook.new(@position, @color_binary)
                    when 3 then Bishop.new(@position, @color_binary)
                    when 4 then Knight.new(@position, @color_binary)
                    end
            board_obj.pieces_arr.push(piece)
            puts "Your #{piece.instance_class_name} was created"
            board_obj.display
            break
          else
            puts "Invalid input. Please enter a number between 1 and 4."
          end
        end
      end
    end
    
    
    


end

class Bishop < Piece
    
    include QueenRookBishopTakeAndMove
    MOVE_SET = [[1,1],[1,-1],[-1,-1],[-1,1]]
    SYMBOL_CHOICES = ["♗","♝"]

    


       

end

class Rook < Piece
   
    include QueenRookBishopTakeAndMove
    MOVE_SET = [[0,1],[1,0],[-1,0],[0,-1]]
    SYMBOL_CHOICES = ["♖","♜"]
end

class Knight < Piece
    
    MOVE_SET = [[2,1],[2,-1],[-2,-1],[-2,1],[1,2],[1,-2],[-1,2],[-1,-2]]
    SYMBOL_CHOICES = ["♘","♞"]

    def move?(board_obj, aimX, aimY)
        current_x, current_y = position[0], position[1]
        MOVE_SET.each do |move|
          next_x, next_y = current_x + move[0], current_y + move[1]
          return true if next_x == aimX && next_y == aimY && on_board?(next_x, next_y) && board_obj.find_piece_at(next_x, next_y).nil?
        end
        false
    end
      

    def take?(board_obj, aimX, aimY)
        current_x, current_y = position[0], position[1]
        MOVE_SET.each do |move|
          next_x, next_y = current_x + move[0], current_y + move[1]
          if next_x == aimX && next_y == aimY && on_board?(next_x, next_y)
            target_piece = board_obj.find_piece_at(next_x, next_y)
            return false if target_piece.nil?
            return true if target_piece.color != @color
          end
        end
        false
    end
      
end

class Queen < Piece
    
    include QueenRookBishopTakeAndMove
    MOVE_SET = [[0,1],[1,0],[-1,0],[0,-1],[1,1],[1,-1],[-1,-1],[-1,1]] #BFS
    SYMBOL_CHOICES = ["♕","♛"]


end

class King < Piece
  attr_accessor :symbol
   
    MOVE_SET = [[0,1],[1,1],[1,0],[1,-1],[0,-1],[-1,1],[-1,0],[-1,-1]].freeze
    SYMBOL_CHOICES = ["♕","♛"]

    def move?(board_obj, destinationX, destinationY)
        MOVE_SET.each do |move|
          next_x, next_y = @position[0] + move[0], @position[1] + move[1]
          return true if next_x == destinationX && next_y == destinationY && on_board?(next_x, next_y) && board_obj.find_piece_at(next_x, next_y).nil?
        end
        false
      end
      

      def take?(board_obj, aimX, aimY)
        current_x, current_y = position[0], position[1]
        MOVE_SET.each do |move|
          next_x, next_y = current_x + move[0], current_y + move[1]
          if next_x == aimX && next_y == aimY && on_board?(next_x, next_y)
            piece = board_obj.find_piece_at(next_x, next_y)
            return true if piece && piece.color != @color
          end
        end
        false
    end
      
end

class Pawn < Piece
    
    attr_accessor :move_set, :capture_move_set, :SYMBOL_CHOICES
    SYMBOL_CHOICES = ["♙","♟"]

    def utilities
        if @color == COLOR0
            @move_set = [[0,1], [0,2]]
            @capture_move_set = [[-1,1], [1,1]]
        else
            @move_set = [[0,-1], [0,-2]]
            @capture_move_set = [[1,-1], [-1,-1]]
        end
    end

    def move?(board_obj, destinationX, destinationY)
        if @moved == true && @move_set == [[0,1], [0,2]]
          @move_set = [[0,1]]
        end
        if @moved == true && @move_set == [[0,-1], [0,-2]]
          @move_set = [[0,-1]]
        end

        @move_set.each do |move|
          next_x, next_y = @position[0] + move[0], @position[1] + move[1]
          return true if next_x == destinationX && next_y == destinationY && on_board?(next_x, next_y) && board_obj.find_piece_at(next_x, next_y).nil?
        end
        false
    end
      

    def take?(board_obj, aimX, aimY)
        current_x, current_y = position[0], position[1]
        @move_set.each do |move|
          next_x, next_y = current_x + move[0], current_y + move[1]
          if next_x == aimX && next_y == aimY && on_board?(next_x, next_y)
            piece = board_obj.find_piece_at(next_x, next_y)
            return true if piece && piece.color != @color
          end
        end
        false
    end




end

