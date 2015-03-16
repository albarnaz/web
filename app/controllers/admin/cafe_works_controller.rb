# encoding:UTF-8
class Admin::CafeWorksController < ApplicationController
  before_filter :authenticate
  before_action :set_cafe_work, only: [:edit, :show, :update, :destroy, :remove_worker]

  def show
  end

  def new
    @cwork = CafeWork.new
  end

  def edit
  end

  def create
    @cwork = CafeWork.new(c_w_params)
    flash[:notice] = 'Cafejobbet skapades, success.' if @cwork.save
    respond_with @cwork
  end

  def update
    if @cwork.update(c_w_params)
      flash[:notice] = 'Cafejobbet uppdaterades'
      redirect_to @cwork
    else
      render action: :edit
    end
  end

  def destroy
    # Id used to hide element
    @id = @cwork.id
    @cwork.destroy
    respond_to do |format|
      format.html { redirect_to :hilbert, notice: 'Cafepasset raderades.' }
      format.js
    end
  end

  def remove_worker
    if !@cwork.clear_worker
      render action: show, notice: "Lyckades inte"
    end
  end

  def setup
    @cwork = CafeWork.new
  end

  def setup_create
    r = CafeSetupWeek.new(Time.zone.parse(params[:cafe_work][:work_day]), params[:cafe_work][:lp])
    @cwork = CafeWork.new(c_w_params)
    if preview?
      @cworks = r.preview(@lv_first = params[:lv_first].to_i, @lv_last = params[:lv_last].to_i)
    elsif save?
      r.setup(params[:lv_first].to_i, params[:lv_last].to_i)
      flash[:notice] = "Skapades"
    end
    render 'setup'
  end

  def main
    @faqs = Faq.category(:Hilbert).answered
    @faq_unanswered = Faq.category(:Hilbert).where(answer: '').count
    @cworks = CafeWork.all
    @cwork_grid = initialize_grid(@cworks)
  end

  private
# For authenticating admin for page
# /d.wessman
  def authenticate
    redirect_to(:hilbert, alert: t('the_role.access_denied')) unless current_user && current_user.moderator?(:cafejobb)
  end

  def c_w_params
    params.require(:cafe_work).permit(:work_day, :pass, :profile_id,
                                      :name, :lastname, :phone, :email, :lp, :lv,
                                      :utskottskamp, :council_ids => [])
  end

  def set_cafe_work
    @cwork = CafeWork.find_by_id(params[:id])
    if (@cwork == nil)
      flash[:notice] = 'Hittade inget Cafejobb med det ID:t.'
      redirect_to(:admin_cafe_works)
    end
  end

  def preview?
    params[:commit] == 'Förhandsgranska'
  end

  def save?
    params[:commit] == 'Spara'
  end

end