class Admin::AdventuresController < Admin::BaseController
  load_permissions_and_authorize_resource

  def index
    @grid = initialize_grid(@adventures, order: :start_date, locale: :sv)
  end

  def new
  end

  def create

    if @adventure.save
      redirect_to admin_adventures_path, notice: alert_create(Adventure)
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    if @adventure.update(adventure_params)
      redirect_to(admin_adventures_path, notice: alert_update(Adventure))
    else
      render :edit, status: 422
    end
  end

  def destroy
    @adventure.destroy!
    redirect_to(admin_adventures_path, notice: alert_destroy(Adventure))
  end

  private

  def adventure_params
    params.require(:adventure).permit(:title_sv, :title_en, :content_sv, :content_en,
                                      :max_points, :start_date, :end_date,
                                      :video, :publish_results, :introduction_id)
  end
end
