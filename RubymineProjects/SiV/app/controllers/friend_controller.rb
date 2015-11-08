class FriendController < ApplicationController
   def index
    @friend = Friend.all
      respond_to do |format|
     format.html
     format.json { render json: @friend }
    end
  end
end
