# encoding: UTF-8
class Admin::ElectionsController < Admin::BaseController
  load_permissions_and_authorize_resource find_by: :url

  def new
    @posts = Post.title
  end

  def show
    @posts = Post.title
  end

  def edit
    @posts = Post.title
  end

  def index
    @elections = Election.order(start: :desc)
  end

  def create
    if @election.save
      redirect_to admin_election_path(@election), notice: alert_create(Election)
    else
      render :new, status: 422
    end
  end

  def update
    if @election.update(election_params)
      redirect_to admin_election_path(@election), notice: alert_update(Election)
    else
      render :show, status: 422
    end
  end

  def destroy
    @election.destroy!
    redirect_to admin_elections_path, notice: alert_destroy(Election)
  end

  def nominations
    @nominations_grid = initialize_grid(@election.nominations,
                                        name: 'nominations',
                                        include: :post)
  end

  def candidates
    @candidates_grid = initialize_grid(@election.candidates,
                                       name: 'candidates',
                                       include: [:post, :user])
  end

  private

  def election_params
    params.require(:election).permit(:title, :description, :start, :end, :closing, :url,
                                   :visible, :mail_link, :mail_styrelse_link, :text_before,
                                   :text_during, :text_after, :nominate_mail, :candidate_mail,
                                   :extra_text, :candidate_mail_star, post_ids: [])
  end
end
