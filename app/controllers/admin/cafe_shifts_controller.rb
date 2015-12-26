# encoding:UTF-8
class Admin::CafeShiftsController < ApplicationController
  skip_authorization
  before_action :authorize

  def show
    @cafe_shift = CafeShift.find(params[:id])
    @cafe_shift.cafe_worker || @cafe_shift.build_cafe_worker
    @users = User.all_firstname
  end

  def edit
    @cafe_shift = CafeShift.find(params[:id])
  end

  def new
    @cafe_shift = CafeShift.new
  end

  def overview
    @cafe_shift_grid = initialize_grid(CafeShift.all_start.with_worker)
  end

  def create
    @cafe_shift = CafeShift.new(shift_params)
    if @cafe_shift.save
      redirect_to admin_cafe_shift_path(@cafe_shift), notice: alert_create(CafeShift)
    else
      render :new
    end
  end

  def update
    @cafe_shift = CafeShift.find(params[:id])
    if @cafe_shift.update(shift_params)
      redirect_to admin_cafe_shift_path(@cafe_shift), notice: alert_update(CafeShift)
    else
      render action: :edit
    end
  end

  def destroy
    shift = CafeShift.find(params[:id])
    @id = shift.id
    shift.destroy!
    respond_to do |format|
      format.html { redirect_to admin_cafe_shifts_path, alert: alert_destroy(CafeShift) }
      format.js
    end
  end

  def index
    @cafe_shift_grid = initialize_grid(CafeShift,
                                       include: :user, order: :start,
                                      conditions: ['start >= ?', Time.zone.now.beginning_of_day]  )
  end

  def setup
    @cafe_shift = CafeShift.new
  end

  def setup_create
    @cafe_shift = CafeShift.new(shift_params)
    if CafeService.setup(shift_params[:lv], shift_params[:lv_last],
                         Time.zone.parse(shift_params[:start]), shift_params[:lp])
      redirect_to(admin_cafe_shifts_path, notice: alert_create(CafeShift))
    else
      render :setup
    end
  end

  private

  def authorize
    authorize! :manage, CafeShift
  end

  def shift_params
    params.require(:cafe_shift).permit(:start, :pass, :lp, :lv, :lv_last)
  end

  def worker_params
    params.require(:cafe_worker).permit(:user_id, :competition, :group)
  end
end
