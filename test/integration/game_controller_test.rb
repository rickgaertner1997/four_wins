
require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = Game.new
    @game.init_board
    @game.save!
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should show game as HTML" do
    get game_url(@game)
    assert_response :success
  end

  test "should show game as JSON" do
    get game_url(@game, format: :json)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @game.id, body["id"]
    assert_equal @game.current_player, body["current_player"] # "player_one" / "player_two"
    assert_equal @game.winner, body["winner"]                 # "none"
  end

  test "should create game" do
    assert_difference("Game.count", 1) do
      post games_url, as: :json
    end

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal "player_one", body["current_player"]
    assert_equal "none", body["winner"]
    assert_equal 0, body["moves_count"]
  end

  test "drop_token should place a token and toggle player" do
    column_index = 0
    old_player = @game.current_player

    post drop_token_game_url(@game), params: { column_index: column_index }, as: :json
    assert_response :success

    @game.reload

    # board[column][row]; one token should be placed in this column
    column = @game.board[column_index]
    assert_equal 1, column.count { |cell| cell != 0 }, "expected exactly one token in the column"

    # current_player should have toggled
    refute_equal old_player, @game.current_player
  end

  test "drop_token returns updated state JSON" do
    post drop_token_game_url(@game), params: { column_index: 0 }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @game.id, body["id"]
    assert_includes %w[player_one player_two], body["current_player"]
    assert_equal "none", body["winner"]
    assert_equal 1, body["moves_count"]
  end

  test "drop_token on finished game returns error" do
    @game.winner = :one
    @game.save!

    post drop_token_game_url(@game), params: { column_index: 0 }, as: :json
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_match /Game is already finished/i, body["error"]
  end

  test "drop_token with invalid column returns error" do
    post drop_token_game_url(@game), params: { column_index: 999 }, as: :json
    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_match /Column is out of the range/i, body["error"]
  end

  test "reset should reinitialize board and state" do
    # make a move so board + moves_count change
    post drop_token_game_url(@game), params: { column_index: 0 }, as: :json
    @game.reload
    assert_operator @game.moves_count, :>, 0

    post reset_game_url(@game), as: :json
    assert_response :success

    @game.reload

    @game.board.each do |column|
      assert column.all? { |cell| cell == 0 }, "expected all cells to be zero after reset"
    end

    assert_equal "player_one", @game.current_player
    assert_equal "none", @game.winner
    assert_equal 0, @game.moves_count
  end
end
