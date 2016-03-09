class HomeController < ApplicationController
  def index
    @pieces = StrategoGame::PIECES
  end
end
