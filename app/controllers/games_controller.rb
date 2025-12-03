class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :drop_token, :reset ]

  def index
    @games = Game.all.order(created_at: :desc)
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: game_state(@game) }
    end
  end

  def create
    @game = Game.new
    @game.init_board

    if @game.save
      respond_to do |format|
        format.html { redirect_to @game, notice: "New game started." }
        format.json { render json: game_state(@game), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @game.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def drop_token
    column_index = params.require(:column_index).to_i

    @game.drop_token!(column_index)

    respond_to do |format|
      format.html { redirect_to @game }
      format.json { render json: game_state(@game), status: :ok }
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to @game, alert: e.message }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  def reset
    @game.init_board
    @game.save!
    respond_to do |format|
      format.html { redirect_to @game, notice: "Game reset." }
      format.json { render json: game_state(@game), status: :ok }
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit()
  end

  # Serialize game state for JSON responses
  def game_state(game)
    {
      id:            game.id,
      board:         game.board,
      current_player: game.current_player,
      winner:         game.winner,
      moves_count:    game.moves_count,
      finished:       game.finished?,
      draw:           game.draw?
    }
  end
end
