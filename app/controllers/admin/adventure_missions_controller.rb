class Admin::AdventureMissionsController < Admin::BaseController
  before_action :load_permissions
  load_and_authorize_resource :adventure
  load_and_authorize_resource :adventure_mission, through: :adventure

  def index
    @grid = initialize_grid(@adventure_missions, locale: :sv, order: 'adventure_missions.index')
  end

  def new
    @adventure_mission = AdventureMission.new
    @suggested_index = @adventure.adventure_missions.count
  end

  def create
    @adventure_mission = AdventureMission.new(adventure_mission_params)

    AdventureMissionService.shift_index_on_create(@adventure, adventure_mission_params[:index].to_i)

    @adventure_mission.adventure = @adventure

    if @adventure_mission.save!
      redirect_to admin_adventure_adventure_missions_path(@adventure), notice: alert_create(Adventure)
    else
      render :new, status: 422
    end
  end

  def update
    AdventureMissionService.shift_index_on_update(@adventure, @adventure_mission.index, adventure_mission_params[:index].to_i)

    if @adventure_mission.update(adventure_mission_params)
      redirect_to(admin_adventure_adventure_missions_path(@adventure), notice: alert_update(Adventure))
    else
      render :edit, status: 422
    end
  end

  def destroy
    AdventureMissionService.shift_index_on_destroy(@adventure, @adventure_mission.index.to_i)

    if @adventure_mission.destroy!
      redirect_to(admin_adventure_adventure_missions_path(@adventure), notice: alert_destroy(Adventure))
    else
      render :edit, status: 422
    end
  end

  def edit
    @adventure_mission = AdventureMission.find(params[:id])
  end

  private

  def adventure_mission_params
    params.require(:adventure_mission).permit(:title_sv, :title_en, :description_sv, :description_en, :max_points, :variable_points, :index)
  end
end
