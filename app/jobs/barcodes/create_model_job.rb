# frozen_string_literal: true

module Barcodes
<<<<<<< HEAD
  class CreateModelJob < AbsoluteIds::CreateModelJob
=======
  class CreateModelJob < AbsoluteId::CreateModelJob
>>>>>>> [WIP] Refactoring ApplicationJobs and implementing support for the generation of barcodes without AbIDs
    def self.aspace_source_job
      CreateModelFromAspaceJob
    end

    def self.marc_source_job
      CreateModelFromMarcJob
    end
  end
end
