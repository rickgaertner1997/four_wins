class GameController < ApplicationController
    def index
        @game = Game.new
        @game.init_board
        @game.save!
    end

    def reset
        @game = Game.find(params[:id])
        @game.destroy
        @game.
    end

    def move
    end
end
