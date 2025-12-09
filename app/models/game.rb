class Game < ApplicationRecord
  BOARD_COLUMNS = 7
  BOARD_ROWS    = 6
  STRIKE_CONDITION = 4

  enum :current_player, { player_one: 1, player_two: 2 }, prefix: true
  enum :winner,         { none: 0, one: 1, two: 2 }, prefix: true

  def init_board
    self.board = Array.new(BOARD_COLUMNS) { Array.new(BOARD_ROWS, 0) }
    self.current_player = :player_one
    self.winner = :none
    self.moves_count = 0
  end

  def finished?
    !winner_none? || draw?
  end

  def draw?
    moves_count >= BOARD_COLUMNS * BOARD_ROWS && winner_none?
  end

  def drop_token!(column_index)
    raise "Game is already finished" if finished?
    raise "Column is out of the range" unless column_index.between?(0, BOARD_COLUMNS - 1)

    column = board[column_index]
    selected_row = column.index(0)

    raise "All rows are full in this column" if selected_row.nil?

    self.board[column_index][selected_row] = player_as_integer

    self.moves_count += 1

    if check_for_win?(selected_row, column_index, player_as_integer)
      self.winner = self.current_player_player_one? ? :one : :two
    else
    toggle_player!
    end

    save!
  end

  private

  def winner_none?
    winner == "none"
  end

  def cycle_player
    current_player[(current_player.index(current_player) + 1) % current_player.length]
  end

  def check_for_win?(row_index, column_index, player)
    return true if four_in_a_row?(row_index, player)
    return true if four_in_a_column?(column_index, player)
    true if four_in_diagonal?(row_index, column_index, player)
  end

  def four_in_a_row?(row_index, player)
    cells = self.board.map { |column| column[row_index] }
    consecutive_four?(cells, player)
  end

  def four_in_a_column?(column_index, player)
    cells = self.board[column_index]
    consecutive_four?(cells, player)
  end

  def four_in_diagonal?(row_index, column_index, player)
    # from left down to right up
    step_for_column = 1
    start_column = column_index - amount_of_strike_minus_the_placed_one
    cells = abstract_relevant_cell_in_one_diagonal?(start_column, row_index, step_for_column)
    return true if consecutive_four?(cells, player)
    # from right down to left up
    step_for_column = -1
    start_column = column_index + amount_of_strike_minus_the_placed_one
    cells = abstract_relevant_cell_in_one_diagonal?(start_column, row_index, step_for_column)
    consecutive_four?(cells, player)
  end

  def abstract_relevant_cell_in_one_diagonal?(current_column, row_index, step_for_column)
    cells = []
    counter = 1
    current_row = calculate_current_row(row_index)
    step_for_row = 1

    while counter <= maximum_loops
      counter += 1
      if column_in_range?(current_column) && row_in_range?(current_row)
        cells << board[current_column][current_row]
      end

      current_column = adding_step(current_column, step_for_column)
      current_row = adding_step(current_row, step_for_row)
    end

    cells
  end

  def adding_step(value, step)
    value + step
  end

  def calculate_current_row(row_index)
    row_index - amount_of_strike_minus_the_placed_one
  end

  def column_in_range?(column)
    column >= 0 && column < BOARD_COLUMNS
  end

  def row_in_range?(row)
    row >= 0 && row < BOARD_ROWS
  end

  def maximum_loops
    (amount_of_strike_minus_the_placed_one * 2) + 1
  end

  def amount_of_strike_minus_the_placed_one
    STRIKE_CONDITION - 1
  end

  def consecutive_four?(cells, player)
    strike = 0

    cells.each do |cell|
      if cell == player
        strike += 1
        return true if strike >= STRIKE_CONDITION
      else
        strike = 0
      end
    end

    false
  end

  def toggle_player!
    self.current_player = self.current_player_player_one? ? :player_two : :player_one
  end

  def player_as_integer
    @_player_as_integer = self.current_player_player_one? ? 1 : 2
  end
end
