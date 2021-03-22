class Admin::FreeProgramKsController < ApplicationController
  before_action :set_free_program_k, only: %i[ show edit update destroy ]

  # GET /free_program_ks or /free_program_ks.json
  def index
    @free_program_ks = FreeProgramK.all.sort_by{ |rec| rec.year.to_s + rec.category.name }
  end

  # GET /free_program_ks/1 or /free_program_ks/1.json
  def show
  end

  # GET /free_program_ks/new
  def new
    @free_program_k = FreeProgramK.new
  end

  # GET /free_program_ks/1/edit
  def edit
  end

  # POST /free_program_ks or /free_program_ks.json
  def create
    @free_program_k = FreeProgramK.new(free_program_k_params)

    respond_to do |format|
      if @free_program_k.save
        format.html { redirect_to admin_free_program_ks_path, notice: "Free program k was successfully created." }
        format.json { render :show, status: :created, location: @free_program_k }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @free_program_k.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /free_program_ks/1 or /free_program_ks/1.json
  def update
    respond_to do |format|
      if @free_program_k.update(free_program_k_params)
        format.html { redirect_to admin_free_program_ks_path, notice: "Free program k was successfully updated." }
        format.json { render :show, status: :ok, location: @free_program_k }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @free_program_k.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /free_program_ks/1 or /free_program_ks/1.json
  def destroy
    @free_program_k.destroy
    respond_to do |format|
      format.html { redirect_to admin_free_program_ks_url, notice: "Free program k was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_free_program_k
      @free_program_k = FreeProgramK.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def free_program_k_params
      params.require(:free_program_k).permit(:year, :category_id, :max_k)
    end
end
