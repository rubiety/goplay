$:.unshift(File.dirname(__FILE__))

require 'go/core_ext'
require 'go/board'
require 'go/errors'
require 'go/grid'
require 'go/chain'
require 'go/chain_list'
require 'go/move'
require 'go/scoring'

Go::Board.send(:include, Go::Errors)
Go::Board.send(:include, Go::Move)
Go::Board.send(:include, Go::Scoring)
