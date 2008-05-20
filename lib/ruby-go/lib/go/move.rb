# == Move
# Methods related to making and updating moves.  Dynamically mixed into 
# the Go::Board class.
#
module Go
  module Move
    
    # Makes a Move and returns an array of captures resulting from the move in tuple form
    def move(color, row, column)
      raise Errors::MoveTargetExistsError.new unless grid.get(row, column).nil?
      raise Errors::RuleOfKoError.new if rule_of_ko_move?(color, row, column)
      raise Errors::SuicidalMoveError.new if suicidal_move?(color, row, column)
      
      add_stone(color, row, column)
      compute_move_captures(color, row, column)
    end
    
    def add_stone(color, row, column)
      # Add to Grid:
      grid.set(row, column, color)
      
      # Update Stone Chain List
      update_chain_list_with(color, row, column)
    end
    
    # If 1. The stone is isolated - no friendly neighbor
    #   Create new chain
    # 
    # If 2. Stone has exactly one friendly neighbor
    #   Append to neighbor's chain and recalculate liberties
    # 
    # If 3. Stone has at least two friendly neighbors
    #   Join chains together and append to new chain.
    # 
    def update_chain_list_with(color, row, column)
      neighbors = self.chains.neighbors_of(color, row, column)
      
      if neighbors.size == 0
        self.chains.add(color, row, column)
        
      elsif neighbors.size == 1
        neighbors.first.add_stone(row, column)
        
      else
        new_chain = self.chains.add(color, row, column)
        neighbors.each {|c| new_chain.stones << c.stones }
        neighbors.each {|c| self.chains.remove(c) }
        new_chain.stones_updated!
        
      end
    end
    
    # Compute Move Captures
    # 1. If there are any adjacent opponent strings without liberties, remove them and increase the prisoner count.
    # 2. If the newly placed stone is part of a string without liberties, remove it and increase the prisoner count.
    def compute_move_captures(color, row, column)
      captures = []
      other_color = (color == :white ? :black : :white)
      
      self.chains.of_color(other_color).each {|c| c.recalculate_liberties! }
      captured_chains = self.chains.of_color(other_color).select {|c| c.liberties.size == 0 }
      
      captured_chains.each do |chain|
        chain.stones.each do |row, column|
          captures << [row, column]
          self.grid.set(row, column, nil)
        end
        
        self.chains.remove(chain)
      end
      
      captures
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
