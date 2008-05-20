# == Errors
#
module Go
  module Errors
    # Generic Invalid Move Error
    class InvalidMoveError < StandardError; end

    # Raised when the move target exists
    class MoveTargetExistsError < InvalidMoveError; end

    # The "Rule of Ko" in Go is implemented to prevent repetitive situations 
    # from arising in certain circumstances.
    class RuleOfKoError < InvalidMoveError; end

    # A suicidal move, or one that will result in that stone being immediately 
    # captured, is not allowed.
    class SuicidalMoveError < InvalidMoveError; end
  end
end
