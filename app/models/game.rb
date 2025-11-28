class Game < ApplicationRecord
  BOARD_COLUMNS = 7
  BOARD_ROWS    = 6
  STRIKE_CONDITION = 4

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
    selected_row = column.index(0)

    raise "All rows are full in this column" if selected_row.nil?

    self.board[column_index][selected_row] = player

    self.moves_count += 1

    if check_for_win?(selected_row, column_index, player)
      self.winner = current_player == "player_one" ? :one : :two
      return self.winner
    else
   #   toggle_player!
    end

    save!
  end

  private

  def winner_none?
    return winner == 'none'
  end

  def cycle_player
    current_player[(current_player.index(current_player) + 1) % current_player.length]
  end

  def check_for_win?(row_index, column_index, player)
    return true if four_in_a_row?(row_index, player)
    return true if four_in_a_column?(column_index, player)
  end

  def four_in_a_row?(row_index, player)
    strike = STRIKE_CONDITION
    self.board.each do |column|
      strike -= 1 if column[row_index] == player
      strike = STRIKE_CONDITION if column[row_index] != player
      return true if strike <= 0
    end
    return false
  end

  def four_in_a_column?(column_index, player)
    strike = STRIKE_CONDITION
    self.board[column_index].each do |row|
      strike -= 1 if row == player
      strike = STRIKE_CONDITION if row != player
      return true if strike <= 0
    end
    return false
  end

  def four_in_a_dialoginal?(row_index, column_index, player)
  end

end
