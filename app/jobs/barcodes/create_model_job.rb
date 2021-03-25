# frozen_string_literal: true

module Barcodes
  class CreateModelJob < AbsoluteId::CreateModelJob
    def self.aspace_source_job
      CreateModelFromAspaceJob
    end

    def self.marc_source_job
      CreateModelFromMarcJob
    end
  end
end
