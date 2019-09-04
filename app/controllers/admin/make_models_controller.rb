class Admin::MakeModelsController < ApplicationController
  before_action :authorize_curator

  def index
    @make_models = MakeModel.all.order(:make, :model)
  end

  def edit
    load_mm
  end

  def update
    mm = load_mm
    begin
      mm.update_attributes(mm_params)
      flash[:notice] = "Updated #{mm.make}, #{mm.model}"
      redirect_to admin_make_models_url
    rescue ActiveRecord::RecordNotUnique,
           ActiveRecord::StatementInvalid => e
      other = MakeModel.find_by(
        make: mm_params[:make], model: mm_params[:model])
      mm.reload
      @merge_models = [mm, other]
      @target_id = other.id
      flash[:alert] = "Make and model exists, suggesting a merge"
      render :merge_preview
    end
  end

  def merge_preview
    selected = params.fetch('selected', {}).keys
    if 1 < selected.count
      @merge_models = selected.collect do |mmid|
        MakeModel.find(mmid)
      end
      iparms = params.select do |key, value|
        key.to_i != 0 && value == "merge"
      end
      targets = selected & iparms.keys
      @target_id = targets.empty? ? selected[0].to_i : targets[0].to_i
    else
      flash[:alert] = 'select two or more make and model to merge'
      redirect_to admin_make_models_url
    end
  end

  def merge
    target_id = params.fetch('target', 0).to_i
    selected_ids = params.fetch('selected', {}).keys.collect(&:to_i)
    selected_ids -= [target_id]
    if 0 < target_id && 0 < selected_ids.count
      target = MakeModel.find(target_id)
      selected_ids.each do |select_id|
        source = MakeModel.find(select_id)
        MakeModelService.new(target, source).merge
      end
      flash[:notice] = "Merged airplanes into #{target.make}, #{target.model}"
    else
      return head :bad_request
    end
    redirect_to admin_make_models_path
  end

  #######
  private
  #######

  def load_mm
    @make_model ||= MakeModel.find(params[:id])
  end

  def mm_params
    params.require(:make_model).permit(
      :make, :model,
      :empty_weight_lbs, :max_weight_lbs,
      :horsepower, :seats, :wings
    )
  end

  def authorize_curator
    authenticate(:curator)
  end
end
