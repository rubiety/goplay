# == Board Grid
# Represents a board grid in matrix form with some utility methods 
# for positioning.
#
module Go
  class Grid
    attr_accessor :matrix
    
    def initialize(size)
      @matrix = (1..size).inject([]) {|grid, row_index| grid << Array.new(size)}
    end
    
    def get(row, column)
      return nil if row >= @matrix.size or column >= @matrix.size
      @matrix[row][column]
    end
    
    def set(row, column, value)
      return nil if row >= @matrix.size or column >= @matrix.size
      @matrix[row][column] = value
    end
    
    def stone_count
      count = 0
      @matrix.each do |row|
        row.each do |cell|
          count += 1 if !cell.nil?
        end
      end
      count
    end
    
    def stone_count_for(color)
      count = 0
      @matrix.each do |row|
        row.each do |cell|
          count += 1 if cell == color.to_sym
        end
      end
      count
    end
    
    def occupied?(row, column)
      !get(row, column).nil?
    end
    
    def free?(row, column)
      get(row, column).nil?
    end
    
    def free_spaces
      spaces = []
      @matrix.each_with_index do |row, row_index|
        row.each_with_index do |column, column_index|
          spaces << [row_index, column_index] if column.nil?
        end
      end
      spaces
    end
    
    def offset_of(row, column, row_offset, column_offset)
      r = row.to_i + row_offset.to_i
      c = column.to_i + column_offset.to_i
      return nil if r < 0 or c < 0
      return nil if r >= @matrix.size or c >= @matrix.size
      return r, c
    end
    
    def north_of(row, column); offset_of(row, column, -1, 0); end
    def south_of(row, column); offset_of(row, column, 1, 0); end
    def east_of(row, column); offset_of(row, column, 0, 1); end
    def west_of(row, column); offset_of(row, column, 0, -1); end
    def northeast_of(row, column); offset_of(row, column, -1, 1); end
    def northwest_of(row, column); offset_of(row, column, 1, 1); end
    def southeast_of(row, column); offset_of(row, column, -1, -1); end
    def southwest_of(row, column); offset_of(row, column, 1, -1); end
    
    def neighbors_of(row, column)
      [north_of(row, column), east_of(row, column), south_of(row, column), west_of(row, column)].compact
    end
    
    def free_neighbors_of(row, column)
      neighbors_of(row, column).select {|r, c| free?(r, c) }
    end
    
    def occupied_neighbors_of(row, column)
      neighbors_of(row, column).select {|r, c| occupied?(r, c) }
    end
    
    def to_s
      @matrix.map do |row|
        row.map {|column| column.nil? ? ' . ' : {:black => ' B ', :white => ' W '}[column] }.join('')
      end.join("\n")
    end
    
    def to_a
      @matrix
    end
  end
end
