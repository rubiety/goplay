# == Piece Capture
# Represents a particular piece capture in time resulting 
# from an opponent's move.  Captures are recorded not only 
# for historical data but because they count towards the final 
# score in Go.
# 
class Capture < DataMapper::Base
  property :move_id, :integer
  property :row, :integer
  property :column, :integer
  
  belongs_to :move
end
