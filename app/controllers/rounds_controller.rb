class RoundsController < ApplicationController

  def create
    location = {lat: params[:lat], lng: params[:lng],radius: params[:radius]}
    round_key = Round.makeKey
    round = Round.new(key: round_key)
    # User.create(name: params[:name], round_id: round.id)
    session[:creator] = true
    if location && round.save
      helpers.get_restaurants(round, location)
      if round.restaurants.length > 0
        redirect_to round
      else
        @error = "No results!"
        flash.now[:notice] = 'No results!'
        render 'home/index'
        #render root, flash.now.alert = "No restaurants in your area"
      end
    else
      redirect_to '/'
    end
  end

  def show
      @round = Round.find(params[:id])
  end


  def destroy
  end

  def find_key
    @round = Round.find_by(key: params[:key])
    # @user = User.create(name: params[:name], round_id: @round.id) if @round
    # session[:user_id] = @user.id
    if @round
      redirect_to @round
    else
      redirect_to '/'
    end
  end

  def start
    @round = Round.find(params[:round_id])
    @restaurants = @round.restaurants
  end

  def results
    @round = Round.find(params[:id])
    @round.update_attribute(:completed, true)
    @winner = @round.restaurants.order(votes: :desc).limit(1).first
    @winner.update_attribute(:winner, true)
    @winner_page = render 'rounds/results', layout: false, locals: { winner: @winner }
    ActionCable.server.broadcast "rounds_channel_#{@round.id}",
                                  body: @winner_page
  end


end
