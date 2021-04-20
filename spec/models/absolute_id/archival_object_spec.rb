# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AbsoluteId::ArchivalObject, type: :model do
  #   def self.resource_class
  #     LibJobs::ArchivesSpace::ArchivalObject
  #   end
  #
  #   has_and_belongs_to_many :top_containers, join_table: 'archival_objects_top_containers'
  #   def json_properties
  #     super.merge({
  #                   ref_id: json_object.ref_id,
  #                   title: json_object.title,
  #                   level: json_object.level
  #                 })
  #   end

  subject(:archival_object) do
    described_class.new(**model_attributes)
  end
  let(:uri) { 'http://localhost.localdomain:80' }
  let(:create_time) { Date.now }
  let(:updated_at) { Date.now }
  let(:model_attributes) do
    {
      create_time: create_time,
      uri: uri,
      updated_at: updated_at
    }
  end
  let(:json_object) do
    {
      id: 1,
      create_time: created_at,
      lock_version: "1",
      system_mtime: "2021-01-23T18:03:11Z",
      uri: uri,
      updated_at: updated_at
    }
  end
  let(:json_resource) { JSON.generate(json_object) }

  describe '.resource_class' do
    it 'returns the API client Class' do
      expect(described_class.resource_class).to eq(LibJobs::ArchivesSpace::ArchivalObject)
    end
  end

  describe '#uri' do
    it 'accesses the URI for the model' do
      expect(archival_object.uri).to eq(uri)
    end
  end

  describe '#created_at' do
    it 'accesses the creation time for the model' do
      expect(archival_object.created_at).to eq('foo')
    end
  end

  describe '#updated_at' do
    it 'accesses the updated time for the model' do
      expect(archival_object.updated_at).to eq('foo')
    end
  end

  describe '#json_resource' do
    it 'generate the JSON-serialization for the model' do
      expect(archival_object.json_resource).not_to be_empty

      json_object = JSON.parse(archival_object.json_resource)
      expect(json_object).to include(foo: 'bar')
    end
  end

  describe '#json_properties' do
    it 'generates the Hash used to build the JSON' do
      expect(archival_object.json_properties).to include(json_object)
      expect(archival_object.json_properties).to include(ref_id: 'foo')
      expect(archival_object.json_properties).to include(title: 'foo')
      expect(archival_object.json_properties).to include(level: 'foo')
    end
  end
end
