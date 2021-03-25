# frozen_string_literal: true
module Barcodes
<<<<<<< HEAD
  class CreateModelFromAspaceJob < AbsoluteIds::CreateModelFromAspaceJob
=======
  class CreateModelFromAspaceJob < AbsoluteId::CreateModelFromAspaceJob
>>>>>>> [WIP] Refactoring ApplicationJobs and implementing support for the generation of barcodes without AbIDs
    def perform(properties:, user_id:)
      @user_id = user_id

      model_attributes = build_model_attributes(**properties.deep_dup)
      model_attributes[:index] = build_model_index(**model_attributes)
      create_absolute_id(**model_attributes)
    end
  end
end
