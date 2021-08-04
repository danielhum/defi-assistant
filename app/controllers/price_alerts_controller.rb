class PriceAlertsController < ApplicationController
  http_basic_authenticate_with name: ENV['USERNAME'], password: ENV['PASSWORD']

  before_action :set_price_alert, only: %i[ show edit update destroy ]

  # GET /price_alerts or /price_alerts.json
  def index
    @price_alerts = PriceAlert.all
  end

  # GET /price_alerts/1 or /price_alerts/1.json
  def show
  end

  # GET /price_alerts/new
  def new
    @price_alert = PriceAlert.new
  end

  # GET /price_alerts/1/edit
  def edit
  end

  # POST /price_alerts or /price_alerts.json
  def create
    @price_alert = PriceAlert.new(price_alert_params)

    respond_to do |format|
      if @price_alert.save
        format.html { redirect_to @price_alert, notice: "Price alert was successfully created." }
        format.json { render :show, status: :created, location: @price_alert }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @price_alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /price_alerts/1 or /price_alerts/1.json
  def update
    respond_to do |format|
      if @price_alert.update(price_alert_params)
        format.html { redirect_to @price_alert, notice: "Price alert was successfully updated." }
        format.json { render :show, status: :ok, location: @price_alert }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @price_alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /price_alerts/1 or /price_alerts/1.json
  def destroy
    @price_alert.destroy
    respond_to do |format|
      format.html { redirect_to price_alerts_url, notice: "Price alert was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_price_alert
      @price_alert = PriceAlert.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def price_alert_params
      params.require(:price_alert).permit(:coin, :currency, :price, :last_price)
    end
end
