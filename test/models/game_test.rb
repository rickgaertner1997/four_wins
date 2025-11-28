require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @game = Game.new
    @game.init_board
  end

  test 'correct init board' do
    new_game = Game.new
    assert_nil new_game.board
    assert_nil new_game.current_player
    assert_nil new_game.winner
    assert_nil new_game.moves_count

    new_game.init_board

    assert new_game.board, [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    assert new_game.current_player, 'player_one'
    assert new_game.winner, 'none'
    assert new_game.moves_count, 0
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
end
