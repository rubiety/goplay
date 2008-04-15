module Go
  module Move
    
    # Makes a Move and returns an array of captures resulting from the move in tuple form
    def make_move(color, row, column)
      raise Errors::MoveTargetExistsError.new unless grid.get(row, column).nil?
      raise Errors::RuleOfKoError.new if rule_of_ko_move?(color, row, column)
      raise Errors::SuicidalMoveError.new if suicidal_move?(color, row, column)
      
      add_stone(color, row, column)
      compute_move_captures(color, row, column)
    end
    
    def add_stone(color, row, column)
      # Add to Grid:
      grid.set(row, column, color)
      
      # Update Stone String List
      update_group_list_with(color, row, column)
    end
    
    # If 1. The stone is isolated - no friendly neighbor
    #   Create new group
    # 
    # If 2. Stone has exactly one friendly neighbor
    #   Append to neighbor's string and recalc liberties
    # 
    # If 3. Stone has at least two friendly neighbors
    #  A. If all neighbors are members of the same string, append to string.
    #  B. If neighbors are in different strings, join strings together and append to new string.
    # 
    def update_group_list_with(color, row, column)
      
    end
    
    # Compute Move Captures
    # 1. If there are any adjacent opponent strings without liberties, remove them and increase the prisoner count.
    # 2. If the newly placed stone is part of a string without liberties, remove it and increase the prisoner count.
    def compute_move_captures(color, row, column)
      captures = []
      other_color = (color == :white ? :black : :white)
      neighbor_row, neighbor_column = grid.north_of(row, column)
      
      if grid.get(neighbor_row, neighbor_column) == other_color
        captures << [neighbor_row, neighbor_column]
        grid.set(neighbor_row, neighbor_column, nil)
      end
      captures
      
      []
    end
    
    # Detects a "Rule of Ko" situation, which is not allowed
    def rule_of_ko_move?(color, row, column)
      false
    end
    
    # Detects a "Suicidal Move" situation, which is not allowed.
    # This is the case if
    # 1. There is no neighboring empty intersection.
    # 2. There is no neighboring opponent string with exactly one liberty.
    # 3. There is no neighboring friendly string with more than one liberty.
    def suicidal_move?(color, row, column)
      false
    end
    
  end
end
