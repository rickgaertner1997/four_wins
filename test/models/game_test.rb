require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @game = Game.new
    @game.init_board
    @empty_board = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
  end

  test 'correct init board' do
    new_game = Game.new
    assert_nil new_game.board
    assert_nil new_game.current_player
    assert_nil new_game.winner
    assert_nil new_game.moves_count

    new_game.init_board

    assert_equal @empty_board, new_game.board
    assert_equal 'player_one', new_game.current_player
    assert_equal 'none', new_game.winner
    assert_equal 0, new_game.moves_count
  end 

  test 'correct draw?' do
    assert_not @game.draw?
    # column * row = max moves
    # 7 * 6 = 42
    @game.moves_count = 42
    assert @game.draw?
  end 

  test 'correct finished? by draw only' do
    assert_not @game.finished?
    @game.moves_count = 42
    assert @game.finished?
  end 

  test 'correct finished? by winner' do
    assert_not @game.finished?
    @game.winner = 'one'
    assert @game.finished?
  end 

  test 'correct finished? by both' do
    assert_not @game.finished?
    @game.moves_count = 42
    @game.winner = 'one'
    assert @game.finished?
  end 

   test 'drop token in a full game' do
    column_index = 0

    @game.winner = 'one'
    assert @game.finished?
    assert_raises(RuntimeError, 'Game is already finished') { @game.drop_token!(column_index) }
  end

  test 'drop token with a non existing column' do
    column_index = 12

    assert_not @game.finished?
    assert_raises(RuntimeError, 'Column is out of the range') { @game.drop_token!(column_index) }
  end 

  test 'drop token to a column where all rows are full' do
    column_index = 0

    @game.board = [[1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    assert_raises(RuntimeError, 'All rows are full in this column') { @game.drop_token!(column_index) }
  end

  test 'drop token as third round' do
    column_index = 0

    assert_equal @empty_board, @game.board
    assert_equal "player_one", @game.current_player 
    assert_equal 0, @game.moves_count

    @game.drop_token!(column_index)
    assert_equal [[1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board
    assert_equal "player_two", @game.current_player
    assert_equal 1, @game.moves_count

    @game.drop_token!(column_index)
    assert_equal [[1, 2, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board
    assert_equal "player_one", @game.current_player
    assert_equal 2, @game.moves_count

    @game.drop_token!(column_index)
    assert_equal [[1, 2, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board
    assert_equal "player_two", @game.current_player
    assert_equal 3, @game.moves_count
  end

  test 'drop token in a column and winning for player one' do
    column_index = 0

    @game.board = [[1, 1, 1, 0, 0, 0], [2, 2, 2, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @game.moves_count = 6
    @game.drop_token!(column_index)
    assert_equal [[1, 1, 1, 1, 0, 0], [2, 2, 2, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board 
    assert_equal "one", @game.winner
  end

  test 'drop token and winning for player tw0' do
    column_index = 1

    @game.board = [[1, 1, 1, 0, 0, 0], [2, 2, 2, 0, 0, 0], [1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @game.moves_count = 7
    @game.current_player = "player_two"
    @game.drop_token!(column_index)
    assert_equal @game.board, [[1, 1, 1, 0, 0, 0], [2, 2, 2, 2, 0, 0], [1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    assert_equal @game.winner, "two"
  end

  test 'drop token in a row and winning for player one' do
    column_index = 3

    @game.board = [[1, 2, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @game.moves_count = 6
    @game.drop_token!(column_index)
    assert_equal [[1, 2, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board 
    assert_equal "one", @game.winner
  end

  test 'drop token in a diagonal left down to right up and winning for player one' do
    column_index = 4

    @game.board = [ [0, 0, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [2, 1, 0, 0, 0, 0], [1, 2, 1, 0, 0, 0], [2, 1, 2, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @game.moves_count = 10
    @game.drop_token!(column_index)
    assert_equal [[0, 0, 0, 0, 0, 0], [1, 2, 0, 0, 0, 0], [2, 1, 0, 0, 0, 0], [1, 2, 1, 0, 0, 0], [2, 1, 2, 1, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board 
    assert_equal "one", @game.winner
  end

  test 'drop token in a diagonal right down to left up and winning for player one' do
    column_index = 2

    @game.board = [[0, 0, 0, 0, 0, 0], [1, 2, 1, 2, 1, 2], [2, 1, 2, 0, 0, 0], [1, 2, 1, 0, 0, 0], [2, 1, 2, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    @game.moves_count = 10
    @game.drop_token!(column_index)
    assert_equal [[0, 0, 0, 0, 0, 0],  [1, 2, 1, 2, 1, 2], [2, 1, 2, 1, 0, 0], [1, 2, 1, 0, 0, 0], [2, 1, 2, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]], @game.board 
    assert_equal "one", @game.winner
  end

end
