# frozen_string_literal: true

class BarcodesController < AbsoluteIdsController
  def sessions
    @sessions ||= begin
                    models = AbsoluteId::Session.where(user: current_user)
                    barcode_models = models.select(&:barcode_only?)
                    barcode_models.reverse
                  end
  end

  # GET /barcodes
  # GET /barcodes.json
  def index
    respond_to do |format|
      format.html { render :index }
      format.json { render json: sessions }
    end
  end

  # GET /barcodes/:value
  # GET /barcodes/:value.json
  # GET /barcodes/:value.xml
  def show
    @absolute_id ||= AbsoluteId.find_by(value: value)

    respond_to do |format|
      format.json { render json: @absolute_id }
      format.xml { render xml: @absolute_id }
    end
  end
end
