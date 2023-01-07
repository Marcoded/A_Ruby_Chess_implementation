#rubocop :disable all
require_relative "board"
class Game
    attr_accessor :current_game_player
    def initialize
        @current_game_player = 0
        @game_board = Board.new
        @game_board.delete_all_piece
        @game_board.setup_close_to_chess
        @check_mate = false

    end

    def update_player_turn_from_piece_storage
        king = @game_board.grab_king(0)
        puts "DEBUG update fonction launched"
        @current_game_player = king.storage_turn
        puts "DEBUG Current_game_player is now #{@current_game_player}"

    end

    def update_storage_from_game
        king = @game_board.grab_king(0)
        puts "DEBUG update fonction launched"
        king.storage_turn = @current_game_player
        puts "DEBUG Current_game_player is now #{@current_game_player}"  
    end

    def alternate_player
        return @current_game_player = 1 if @current_game_player == 0
        return @current_game_player = 0 if @current_game_player == 1
    end

    def opponent_player
      return 1 if @current_game_player == 0
      return 0 if @current_game_player == 1
    end

    def square_to_coords
      loop do
        #print "Enter a chess board square (e.g. A2): "
        square = gets.chomp.upcase
        # Check if the square string is 2 characters long
        if square.length != 2
          puts "Error: Invalid square format. Please enter a square in the form 'A2'."
          next
        end
    
        # Convert the square string to an array of characters
        chars = square.split("")
        # Get the column letter and convert it to a number (A = 0, B = 1, etc.)
        col = chars[0].ord - "A".ord
        # Check if the column is a valid chess board column (A-H)
        if col < 0 || col > 7
          puts "Error: Invalid column. Please enter a column between A and H."
          next
        end
        # Get the row number
        row = chars[1].to_i - 1
        # Check if the row is a valid chess board row (1-8)
        if row < 0 || row > 7
          puts "Error: Invalid row. Please enter a row between 1 and 8."
          next
        end
    
        # If we reach this point, the input is valid. Return the tuple of coordinates.

        return [col, row]
      end
    end
    
    
    
      


    def save_load_or_continue
      print "type SAVE , LOAD or press any key to continue  "
      input = gets.chomp
        case input
        when "SAVE"
          update_storage_from_game()
          return @game_board.alba_serialize

        when "LOAD"
          @game_board.full_load_game
          update_player_turn_from_piece_storage()
          return
        end
        return input 
    end

    def select_destination(first_piece) #Return valid arr input
      loop do
        puts "Player #{@current_game_player + 1}, where you you want to move you #{first_piece.instance_class_name}."
        input = square_to_coords

        destination_piece = @game_board.find_piece_at(input[0], input[1])
        @game_board.check_chess_for_one_move(first_piece,opponent_player,input)
        


        if @game_board.find_piece_at(input[0], input[1]).nil?
           if first_piece.move?(@game_board,input[0],input[1])
              return input
           else
              puts "You cannot move this piece there, please select a valid move"
              next
           end
        end

        destination_piece = @game_board.find_piece_at(input[0], input[1])
        if destination_piece.color == @current_game_player
          puts "This spot is occupied by one of you piece"
          next
        end

        if destination_piece.color != @current_game_player
          if first_piece.take?(@game_board,input[0],input[1])
            return input
          else
            puts "You piece cannot move there"
            next
          end

      
        end

      end
    end

    def check_destination
      return
    end

    def player_turn
      @game_board.display
      save_load_or_continue()
      
      start_piece = select_first_piece
      destination = select_destination(start_piece)
      brute_move(start_piece,destination)
      puts "CHESS!" if @game_board.chess?(opponent_player)
      puts "CHECKMATE" if @game_board.check_mate_2?(opponent_player)
      @check_mate = true if @game_board.check_mate_2?(opponent_player)
      @game_board.display
      alternate_player()
      # at this step, the selected move is legal, so we can brute move / delete the piece
    end

    def brute_move(start_piece,destinationXY)
        destination_piece = @game_board.find_piece_at(destinationXY[0],destinationXY[1])
        if destination_piece
          piece.position = destination_piece.position
          puts "Your #{piece.instance_class_name} took the opponent #{destination_piece.instance_class_name}"
          @game_board.pieces_arr.delete(destination_piece)
          
          return
        end

        start_piece.position = [destinationXY[0],destinationXY[1]]
        start_piece.moved = true
        puts "Player #{@current_game_player +1 } moved its #{start_piece.instance_class_name}"
        return
    end

    def select_first_piece
     
      loop do
        puts "Player #{@current_game_player + 1}, enter the coodinates of the piece you want to move."
        input = square_to_coords
        # Check if there is a piece at the specified position
        if @game_board.find_piece_at(input[0], input[1]).nil?
          puts "There is no piece there, please select a valid position."
          next
        end
        # Get the piece at the specified position
        piece = @game_board.find_piece_at(input[0], input[1])
        # Check if the piece belongs to the current l
        if piece.color_binary != @current_game_player
          puts "Please select one of you own pieces."
          next
        end

        if piece.possible_moves_and_take(@game_board).size == 0
          puts "You cannot move this piece anywhere."
          next
        end

        unless @game_board.move_piece_and_check_chess(opponent_player,piece)
          puts "You cannot espace out of chess by moving this piece"
        end


        # If we reach this point, the input is valid. Print a message and return the piece.
        
        return piece
      end
    end

    def game_loop
      loop do
      player_turn
      break if @check_mate == true
      end

    end
     
end

game = Game.new
game.game_loop
