class Game < ApplicationRecord
  BOARD_COLUMNS = 7
  BOARD_ROWS    = 6

  enum :current_player, { player_one: 1, player_two: 2 }, prefix: true
  enum :winner,         { none: 0, one: 1, two: 2 }, prefix: true

  def init_board
    self.board ||= Array.new(BOARD_COLUMNS) { Array.new(BOARD_ROWS, 0) }
    self.current_player ||= :player_one
    self.winner ||= :none
    self.moves_count ||= 0
  end

  def finished?
    !winner_none? || draw?
  end

  def draw?
    moves_count >= BOARD_COLUMNS * BOARD_ROWS && winner_none?
  end

  def drop_token(column_index, player)
    raise "Game is already finished" if finished?
    raise "Column is out of the range" unless column_index.between?(0, BOARD_COLUMNS - 1)

    column = board[column_index]
    first_empty_row = column.find { |row| row == 0 }

    raise "All rows are full in this column" if first_empty_row.nil?

    board[column_index][first_empty_row] = player

    self.moves_count += 1

    if four_in_a_row?(row_index, column_index)
      self.winner = current_player == "player_one" ? :one : :two
    else
      toggle_player!
    end

    save!
  end

  private

  def cycle_player
    current_player[(current_player.index(current_player) + 1) % current_player.length]
  end

  def four_in_a_row?(row_index, column_index)
    
  end
end
