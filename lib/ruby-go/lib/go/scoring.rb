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
      self.grid.stone_count_for(color) + self.capture_count_for(color)
    end
    
  end
end
