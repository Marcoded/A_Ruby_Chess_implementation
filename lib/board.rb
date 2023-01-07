#rubocop : disable all
require_relative "pieces"
require "colorize"
require "json"
require 'alba'


class Board

    attr_accessor :pieces_arr, :current_binary_player
    def initialize
        @bg_color_1 = "light_blue"
        @bg_color_2 = "light_white"
        @pieces_arr = []
        set_up_pawns
        set_up_other_pieces
        
        
    end

    def set_up_pawns
        8.times do |x|
          @pieces_arr << Pawn.new([x, 1], 0)
          @pieces_arr << Pawn.new([x, 6], 1)
        end
    end

    def delete_all_piece
        @pieces_arr = []
    end

    def coordinates_to_position(coordinates)
        x, y = coordinates
        x_position = ('A'.ord + x).chr
        y_position = (y + 1).to_s
        "#{x_position}#{y_position}"
    end
      


    def set_up_other_pieces
        piece_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
      
        piece_order.each_with_index do |piece_class, index|
          @pieces_arr << piece_class.new([index, 0,], 0)
          @pieces_arr << piece_class.new([index, 7], 1)
        end
    end

    def introduce_all_pieces
        @pieces_arr.map {|piece| piece.introduction}
        puts "there are #{@pieces_arr.size} in this board"
    end


    def find_piece_atOLD(x, y)
        @pieces_arr.each do |piece|
          return piece if piece.position == [x, y]
        end
        nil
    end

    def find_piece_at(x, y)
        @pieces_arr.each do |piece|
          if piece.is_a?(Array) && piece[0] == "pieces"
            piece[1].each do |sub_piece|
              return sub_piece if sub_piece["position"] == [x, y]
            end
          else
            return piece if piece.position == [x, y]
          end
        end
        return nil
    end
      

    def grab_first_piece(class_name,color_binary)
        @pieces_arr.each do |piece|
            return piece if (piece.color_binary == color_binary) && (piece.instance_class_name == class_name)
        end
        puts "DEBUG, grab_first_piece did not took anything "
        
    end

    def grab_king(color_binary)
        @pieces_arr.each do |piece|
            return piece if (piece.color_binary == color_binary) && (piece.instance_class_name == "King")
        end

    end

    def setup_a_check_mate
        @pieces_arr = []
        @pieces_arr.push(Rook.new([0,0], 0))
        king = (King.new([0,7], 1))
        @pieces_arr.push(king)
        @pieces_arr.push(King.new([6,3], 0))

        @pieces_arr.push(Queen.new([7,7], 1))
        @pieces_arr.push(Pawn.new([6,6], 0))
        @pieces_arr.push(Pawn.new([5,5], 0))
        @pieces_arr.push(Pawn.new([4,4], 0))
        @pieces_arr.push(Pawn.new([3,3], 0))
        @pieces_arr.push(Pawn.new([2,2], 0))
        @pieces_arr.push(Rook.new([1,1], 0))
        @pieces_arr.push(Pawn.new([0,0], 0))
        
    end

    def setup_another_check_mate
        @pieces_arr = []
        @pieces_arr.push(Rook.new([0,0], 1))
        king = (King.new([0,7], 0))
        @pieces_arr.push(king)
        @pieces_arr.push(King.new([6,3], 1))

        @pieces_arr.push(Queen.new([7,7], 1))
        @pieces_arr.push(Pawn.new([6,6], 1))
        @pieces_arr.push(Pawn.new([5,5], 1))
        @pieces_arr.push(Pawn.new([4,4], 1))
        @pieces_arr.push(Pawn.new([3,3], 1))
        @pieces_arr.push(Pawn.new([2,2], 1))
        @pieces_arr.push(Rook.new([1,1], 1))
        @pieces_arr.push(Pawn.new([0,0], 1))

    end

    def setup_2_pawn
        @pieces_arr = []
        @pieces_arr.push(Pawn.new([0,0],0))
        @pieces_arr.push(Pawn.new([1,7],1))
    end

    def setup_close_to_chess
        @pieces_arr = []
        @pieces_arr.push(King.new([2,7], 1))
        @pieces_arr.push(King.new([7,1], 0))

        @pieces_arr.push(Rook.new([3,1], 0))
        @pieces_arr.push(Rook.new([4,1], 0))
    end

    def chess?(defendant_color_binary) #Says if the defendant king is in chess
    
        chess = false
        defendant_king = grab_king(defendant_color_binary)
        
        
        attacker_pieces = @pieces_arr.select{|piece| piece.color_binary != defendant_color_binary}
        attacker_pieces.each do |piece|
            chess = true if piece.take?(self,defendant_king.position[0],defendant_king.position[1])
            #puts " #{piece.quick_info} is threatening your #{defendant_king.color} king in #{defendant_king.position} " if piece.take?(self,defendant_king.position[0],defendant_king.position[1])
        end
        #puts "CHESS" if chess == true
        #puts "NO Chess" if chess == false
        #puts "you're in chess" if chess == true
        return chess
    end


    def king_direct_escape(defender_color_binary)
        can_escape = false
        defendant_king = grab_king(defender_color_binary)
        puts defendant_king.introduction
        old_pos = defendant_king.position
        
        defendant_king.possible_moves_and_take(self).each do |move|
            defendant_king.position = move
            puts "considering #{move}"
            can_escape = true unless chess?(defender_color_binary)
        end
        defendant_king.position = old_pos
        puts "DIRECT ESCAPE IF #{can_escape}"
        return can_escape
    end

    def move_piece_and_check_chess(defender_color_binary,piece)
        can_escape = false
        old_pos = piece.position
        puts "DEBUG RUNING MOVE PIECE FOR #{piece.quick_info}"
        puts "DEBUG, COLOR BINARY IS #{defender_color_binary}"
        
        piece.possible_moves_and_take(self).each do |move|
            piece.position = move
            #puts "considering #{move}"
            can_escape = true unless chess?(defender_color_binary)
        end
        piece.position = old_pos
        #puts "DIRECT ESCAPE IF #{can_escape}"
        puts "DEBUG can this piece move out #{can_escape}"
        return can_escape
    end

    def check_mate_2?(defendant_color_binary)
        check_mate = true
        
        
        defendant_king = grab_king(defendant_color_binary)
        puts "DEBUG :#{defendant_king.color} is not in chess at the start of the checkmate fonction, Exiting Check_mate2 method " unless chess?(defendant_color_binary)
        return check_mate = false unless chess?(defendant_color_binary)
        defendant_pieces = @pieces_arr.select{|piece| piece.color_binary == defendant_color_binary}
        defendant_pieces.each do |piece|
            check_mate = false if move_piece_and_check_chess(defendant_color_binary,piece)
        end
        puts "#{defendant_king.color} checkmates / lose ?  #{check_mate}"
        return check_mate
        
    end

    def stale_mate?(defendant_color_binary)
        stale_mate = true
        
        
        defendant_king = grab_king(defendant_color_binary)
        puts "DEBUG :#{defendant_king.color} is in chess at the start of the stalemate fonction, Exiting stale_mate2 method " if chess?(defendant_color_binary)
        return stale_mate = false if chess?(defendant_color_binary)
        defendant_pieces = @pieces_arr.select{|piece| piece.color_binary == defendant_color_binary}
        defendant_pieces.each do |piece|
            stale_mate = false if move_piece_and_check_chess(defendant_color_binary,piece)
        end
        puts "#{defendant_king.color} checkmates / lose ?  #{stale_mate}"
        return stale_mate
        
    end

    def check_chess_for_one_move(piece, defender_color_binary,destination_arr)
        chess_for_this_move = false
        old_pos =  piece.position
        piece.position = destination_arr
        chess_for_this_move = true if  chess?(defender_color_binary)
        piece.position = old_pos
        puts "this move will put you in chess ? #{chess_for_this_move}" 
        return chess_for_this_move
    end

    def display  #Working
        x = 0
        y = 7
        color = @bg_color_2
        helper_arr = ["N1","N2","N3","N4","N5","N6","N7","N8"]
        helper_arr_index = [" 0"," 1"," 2"," 3"," 4"," 5"," 6"," 7"]
        8.times do
            color = alternate_board_color(color)
            
            print helper_arr[y].red
            
            print helper_arr_index[y].green
            
            8.times do
                color = alternate_board_color(color)
                piece = find_piece_at(x,y)
                print "  #{piece.symbol}  ".colorize(:color => :"#{piece.display_color}", :background => :"#{color}") unless piece.nil?
                print "     ".colorize(:color => :black, :background => :"#{color}") if piece.nil?
                
                x +=1
            end
            puts ""
            x = 0
            y -= 1  
        end
        puts '      0    1    2    3    4    5    6    7'.green
        puts '      A    B    C    D    E    F    G    H'
         
    end


    def alternate_board_color(color)
        return @bg_color_1 if color == @bg_color_2
        return @bg_color_2 if color == @bg_color_1
    end

    def shuffle
        # Create an array of all possible positions on the board
        positions = (0..7).to_a.product((0..7).to_a)
      
        # Shuffle the positions
        positions.shuffle!
      
        # Assign a shuffled position to each piece in @pieces_arr
        @pieces_arr.each_with_index do |piece, index|
        piece.position = positions[index]
        end
    end

    def alba_serialize
        Dir.mkdir("saved_games") unless File.directory?("saved_games")
        print "Enter a name for the JSON file: "
        file_name = gets.chomp
        serialized_board = SerializerBoard.new(@pieces_arr).serialize
        File.open("saved_games/#{file_name}.json", "w") do |f|
            f.write(serialized_board)
          end
        puts "Game succesfully loaded"  


    end


    def load_JSON_file(json_data)
        @pieces_arr = []

        json_data.each do |piece_data|
            instance_class_name = piece_data["instance_class_name"]
            klass = Object.const_get(instance_class_name)
            new_piece = klass.new(piece_data["position"],piece_data["color_binary"])
            new_piece.color_binary = piece_data["color_binary"]
            new_piece.position = piece_data["position"]
            new_piece.moved = piece_data["moved"]
            @pieces_arr << new_piece
            end
            puts "Game succesfully loaded, here is the board."
            display()
        
          
    end

    def full_load_game
        files = Dir.entries("saved_games")
        puts "Select a file to load:"
        files.each_with_index do |file, index|
            puts "#{index + 1}: #{file}"
        end

        print "Enter a number: "
        selection = gets.chomp.to_i
        file = File.read("saved_games/#{files[selection - 1]}")
        json_data = JSON.parse(file)
        load_JSON_file(json_data)

    end
end

class SerializerBoard
    include Alba::Resource
    root_key :instance_class_name
    attributes :color_binary, :position, :moved, :instance_class_name, :storage_turn
end
=begin
two_pawn_board = Board.new
two_pawn_board.setup_2_pawn


two_pawn_board.alba_serialize
two_pawn_board.full_load_game
=end

























