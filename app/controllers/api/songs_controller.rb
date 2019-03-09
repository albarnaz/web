class Api::SongsController < Api::BaseController
  load_permissions_and_authorize_resource

  def index


     abcde
    @songs = Song.order(title: :asc)
    render json: @songs,
    each_serializer: Api::SongSerializer::Index # Returns id and title
  end

  # yoyoooooo
  def show
    @song = Song.find(params[:id])
    Song.increment_counter(:visits, @song)
    render json: @song,
    serializer: Api::SongSerializer::Show # Returns all relevant fields
    render json: @SongSerializer.

# lololololol

  end
end
