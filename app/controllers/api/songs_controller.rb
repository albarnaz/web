class Api::SongsController < Api::BaseController
  load_permissions_and_authorize_resource

  def index
    @songs = Song.order(title: :asc)
    render json: @songs,
    each_serializer: Api::SongSerializer::Index # Returns id and title
  end

  def hej

  end

  def show
    @song = Song.find(params[:id])
    Song.increment_counter(:visits, @song)
    render json: @song,
    serializer: Api::SongSerializer::Show # Returns all relevant fields
  end
end
<<<<<<< HEAD
<<<<<<< HEAD
# Lol olof e dålig
=======
# Owo "nuzzle"
>>>>>>> b2ff6bae7cc00c039ac7c801dd5f6b013496d535
=======

# Owo "nuzzle"
# Lol olof e dålig
>>>>>>> 8551ca7e12469248adb4b3ce9f27a9cf1ed4b2a4
