# == Scoring
# 
# Important: Traditional Go scoring involves some heavily complex algorithms 
# that analyze and classify territory and analyze "double eye creation potential" 
# among other things.  
#
# For now, the scoring implemented here is a basic scoring system of covered 
# territory (as in, actual stones on the board) plus captures you have made.  This implies 
# that a game ends when ever spot on the board has been filled.  
# 
module Go
  module Scoring
    
    # Compute Scores - intended for the end of a game
    def compute_score_for(color)
      compute_territory_for(color) + capture_count_for(color)
    end
    
    # Does a relatively simple territory calculation.
    # Calculates all of the enclosures, then assigns the enclosure's
    # space count to the territory score if all of the eclosure's "liberties"
    # are stones of the specified color.
    # 
    def compute_territory_for(color)
      calculate_enclosures!
      
      territory_score = 0
      self.enclosures.each do |enclosure|
        if enclosure.liberties.all? {|row, column| self.grid.get(row, column) == color.to_sym }
          territory_score += enclosure.spaces.size
        end
      end
      territory_score
    end
    
    # If 1. The space is isolated - no friendly neighbor
    #   Create new enclosure
    # 
    # If 2. Space has exactly one friendly neighbor
    #   Append to neighbor's enclosure and recalculate liberties
    # 
    # If 3. Space has at least two friendly neighbors
    #   Join enclosures together and append to new enclosure.
    #
    def calculate_enclosures!
      clear_enclosures!
      
      # Go through all the free spaces and populate enclosures
      self.grid.free_spaces.each do |row, column|
        neighbors = self.enclosures.neighbors_of(row, column)
        
        if neighbors.size == 0
          self.enclosures.add(row, column)
        elsif neighbors.size == 1
          neighbors.first.add_space(row, column)
        else
          new_enclosure = self.enclosures.add(color, row, column)
          neighbors.each {|e| new_enclosure.spaces += e.spaces }
          neighbors.each {|e| self.enclosures.remove(e) }
          new_enclosure.spaces_updated!
        end
      end
    end
    
    def clear_enclosures!
      self.enclosures = EnclosureList.new(self)
    end
    
    
  end
end
