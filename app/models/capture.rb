class Capture < DataMapper::Base
  property :move_id, :integer
  property :row, :integer
  property :column, :integer
  
  belongs_to :move
end
