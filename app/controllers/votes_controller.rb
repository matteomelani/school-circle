class VotesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user
  respond_to :json
  
  def create
    @vote = ActsAsVotable::Vote.new(params[:acts_as_votable_vote])
    @vote.voter=@user
    if @vote.save
      render :json=>{:id=>@vote.id, :votable_likes=>@vote.votable.upvotes.count, :score=>@vote.votable.upvotes.count-@vote.votable.downvotes.count}
    else
      m = {:errors=>@vote.errors}
      logger.error("Failed to create vote, returning: #{m} with HTTP status 400.")
      render :json=>m, :status=>400
    end
  end
  
  def destroy
    @vote = ActsAsVotable::Vote.find(params[:id])
    @vote.destroy
    render :json=>{:id=>@vote.id, :votable_likes=>@vote.votable.upvotes.count, :score=>@vote.votable.upvotes.count-@vote.votable.downvotes.count}
  end
  
end