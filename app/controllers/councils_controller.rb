# encoding:UTF-8
class CouncilsController < ApplicationController
  load_permissions_and_authorize_resource
  before_action :set_council, only: [:show, :edit, :update, :destroy]
  before_action :set_councils

  # GET /councils
  # GET /councils.json
  def index
  end

  # GET /councils/1
  # GET /councils/1.json
  def show
    @council = Council.where(url: params[:id]).first
    @page = @council.page
    if @page
      @mainelements = @page.page_elements.where(visible: true, sidebar: false)
      @sidebarelements = @page.page_elements.where(visible: true, sidebar: true)
      if @mainelements.count > 1
        @mainelements = @mainelements.sort_by { |x| x[:displayIndex] }
      end
    end
    @poster = @council.posts
  end

  # GET /councils/new
  def new
    @council = Council.new
  end

  # GET /councils/1/edit
  def edit
    @contact = Contact.all.where(council_id: @council.id).first
    if not @contact
      @contact = Contact.new
      @contact.council_id = @council.id
      @contact.save
    end
  end

  # POST /councils
  def create
    @council = Council.new(council_params)
    @council.build_page(council_id: @council.id)
    if @council.save
      redirect_to edit_council_path(@council), notice: 'Utskott skapades, success.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /councils/1
  # PATCH/PUT /councils/1.json
  def update
    respond_to do |format|
      if @council.update(council_params)
        format.html { redirect_to edit_council_path(@council), notice: 'Utskott uppdaterades!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @council.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /councils/1
  # DELETE /councils/1.json
  def destroy
    @council.destroy
    respond_to do |format|
      format.html { redirect_to councils_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_council
    @council = Council.find_by_url(params[:id])
    @page = @council.page
  end

  def set_councils
    @councils = Council.all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def council_params
    params.require(:council).permit(:title, :url, :description, :president, :vicepresident, :public)
  end
end
