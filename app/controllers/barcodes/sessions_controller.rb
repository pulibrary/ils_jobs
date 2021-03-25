# frozen_string_literal: true

<<<<<<< HEAD
class Barcodes::SessionsController < AbsoluteIds::SessionsController
  skip_forgery_protection if: :token_header?

  def self.create_session_job
    Barcodes::CreateSessionJob
=======
class Barcodes::SessionsController < AbsoluteId::SessionsController
  skip_forgery_protection if: :token_header?

  def self.create_session_job
    Barcodes::CreateSessionJob
  end

  def show
    @session ||= begin
                   AbsoluteId::Session.find_by(user: current_user, id: session_id)
                 end

    if request.format.text?
      render text: @session.to_txt
    else
      respond_to do |format|
        format.json { render json: @session }
        format.yaml { render yaml: @session.to_yaml }
        format.xml { render xml: @session }
      end
    end
>>>>>>> [WIP] Implementing the barcode-only routes
  end

  private

<<<<<<< HEAD
  def current_sessions
    @current_sessions ||= begin
                            models = super.select(&:barcode_only?)
                            models.reverse
                          end
=======
  def session_id
    params[:session_id]
>>>>>>> [WIP] Implementing the barcode-only routes
  end
end
