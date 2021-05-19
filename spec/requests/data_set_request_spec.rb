# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "DataSets", type: :request do
  let(:previous_time) { 3.days.ago.midnight }
  let(:previous_time_string) { previous_time.midnight }
  let(:today) { DateTime.now.midnight }
  let(:today_string) { today.strftime('%Y-%m-%d') }
  let(:today_end_of_hour) { today.end_of_hour }
  let(:today_time_string) { today.strftime('%Y-%m-%d %H:%M:%S %Z') }

  describe "GET /data_sets/new" do
  end

  describe "POST /data_sets" do
  end

  describe "PATCH /data_sets/:id" do
    let(:updated_data) { 'ghi789' }
    let(:data) { 'abc123,def456' }
    let(:data_set1) { create(:data_set, report_time: today, data: data, data_file: nil, category: 'StaffDirectoryRemoved') }
    let(:params) do
      {
        data_set: {
          data: updated_data
        }
      }
    end

    it 'returns a message indicating that the Data Set model was destroyed' do
      patch "/data_sets/#{data_set1.id}", params: params
      expect(DataSet.all).not_to be_empty
      expect(DataSet.last.data).to eq(updated_data)

      expect(response).to redirect_to data_set_path(data_set1)
      follow_redirect!
      # expect(response.body).to include("Data set was successfully updated.")
    end

    context 'when invalid PATCH request parameters are transmitted' do
      let(:params) do
        {
          data_set: {
            invalid: 'invalid'
          }
        }
      end

      it 'does not update the Data Set model and renders the edit action response' do
        patch "/data_sets/#{data_set1.id}", params: params
        expect(DataSet.all).not_to be_empty
        expect(DataSet.last.data).to eq(data)

        expect(response.body).to include("Editing Data Set")
        expect(response.body).to include("unknown attribute &#39;invalid&#39; for DataSet.")
      end
    end

    context 'when requesting a JSON response' do
      let(:headers) do
        {
          "Accept" => "application/json"
        }
      end

      it 'returns a response body with an updated model' do
        patch "/data_sets/#{data_set1.id}", headers: headers, params: params
        expect(DataSet.all).not_to be_empty
        expect(DataSet.last.data).to eq(updated_data)

        expect(response.status).to eq(200)
        expect(response.body).not_to be_empty
        json_response_body = JSON.parse(response.body)
        expect(json_response_body).to include(
          "id" => data_set1.id,
          "created_at" => JSON.parse(data_set1.created_at.to_json),
          "updated_at" => JSON.parse(DataSet.last.updated_at.to_json),
          "url" => data_set_url(data_set1, format: 'json')
        )
      end

      context 'when invalid PATCH request parameters are transmitted' do
        let(:params) do
          {
            data_set: {
              report_time: 'invalid'
            }
          }
        end

        it 'does not update the Data Set model and responds with the error messages' do
          patch "/data_sets/#{data_set1.id}", headers: headers, params: params
          expect(DataSet.all).not_to be_empty
          expect(DataSet.last.data).to eq(data)

          expect(response.status).to eq(200)
          expect(response.body).not_to be_empty
          json_response_body = JSON.parse(response.body)

          expect(json_response_body).to include(
            "id" => data_set1.id,
            "created_at" => JSON.parse(data_set1.created_at.to_json),
            "updated_at" => JSON.parse(DataSet.last.updated_at.to_json),
            "url" => data_set_url(data_set1, format: 'json')
          )
        end
      end
    end
  end

  describe "DELETE /data_sets/:id" do
    let(:data_set1) { create(:data_set, report_time: today, data: "abc123,def456", data_file: nil, category: "StaffDirectoryRemoved") }

    it 'returns a message indicating that the Data Set model was destroyed' do
      delete "/data_sets/#{data_set1.id}"
      expect(DataSet.all).to be_empty
      expect(response).to redirect_to data_sets_url
      follow_redirect!
      # expect(response.body).to include("Data set was successfully destroyed.")
    end

    context 'when requesting a JSON response' do
      let(:headers) do
        {
          "Accept" => "application/json"
        }
      end

      it 'returns a response body with no content' do
        delete "/data_sets/#{data_set1.id}", headers: headers
        expect(DataSet.all).to be_empty
        expect(response.status).to eq(204)
        expect(response.body).to be_empty
      end
    end
  end

  describe "index" do
    let(:data_set1) { create(:data_set, report_time: today, data: "abc123,def456", data_file: nil, category: "StaffDirectoryRemoved") }
    let(:data_set2) { create(:data_set, report_time: today_end_of_hour, data: "abc123,def456", data_file: nil, category: "Other") }
    let(:data_set3) { create(:data_set, report_time: previous_time, data: "zzz999,yyy888", data_file: nil, category: "StaffDirectoryAdded") }

    before do
      data_set3
      data_set2
      data_set1
    end

    it "returns all the datasets" do
      get "/"
      expect(response.body).to include(previous_time.to_s).once
      expect(response.body).to include(today_string).twice
      expect(response.body).to include('StaffDirectoryRemoved').once
      expect(response.body).to include('StaffDirectoryAdded').once
      expect(response.body).to include('Other').once
    end

    it "can be filtered by category" do
      get "/?category=StaffDirectoryAdded"
      expect(response.body).to include(previous_time.to_s).once
      expect(response.body).not_to include('StaffDirectoryRemoved')
      expect(response.body).to include('StaffDirectoryAdded').once
    end

    it "can be filtered by date" do
      get "/?report_date=#{today_string}"
      expect(response.body).to include(today_string).twice
      expect(response.body).to include('StaffDirectoryRemoved')
      expect(response.body).not_to include('StaffDirectoryAdded').once
      expect(response.body).to include('Other').once
    end

    it "can be filtered by an exact time" do
      get "/?report_time=#{today_time_string}"
      expect(response.body).to include(today_string).once
      expect(response.body).to include('StaffDirectoryRemoved')
      expect(response.body).not_to include('StaffDirectoryAdded').once
    end
  end

  describe "latest" do
    context "when the client passes an invalid JSON Web Token" do
      let(:user) do
        User.create(email: 'user@localhost')
      end

      let(:headers) do
        {
          "Accept" => "application/json",
          "Authorization" => "Bearer invalid"
        }
      end

      let(:params) do
        {
          user: { id: user.id }
        }
      end

      before do
        user
      end

      after do
        user.destroy
      end

      it "denies the request" do
        get "/data_sets/latest/other", headers: headers, params: params

        expect(response.forbidden?).to be true
      end
    end

    context "when the client does not pass a user ID" do
      let(:user) do
        User.create(email: 'user@localhost')
      end

      let(:headers) do
        {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{user.token}"
        }
      end

      before do
        user
      end

      after do
        user.destroy
      end

      it "denies the request" do
        get "/data_sets/latest/other", headers: headers

        expect(response.forbidden?).to be true
      end
    end

    context "when the client is authenticated via a token" do
      let(:user) do
        User.create(email: 'user@localhost')
      end

      let(:headers) do
        {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{user.token}"
        }
      end

      let(:params) do
        {
          user: { id: user.id }
        }
      end

      before do
        user
        DataSet.create(report_time: today_end_of_hour, data: "abc123,def456", data_file: nil, status: true, category: "StaffDirectoryRemoved")
        DataSet.create(report_time: today_end_of_hour, data: "other5,other6", data_file: nil, status: false, category: "Other")
        DataSet.create(report_time: today, data: "other3,other4", data_file: nil, status: true, category: "Other")
        DataSet.create(report_time: previous_time, data: "other1,other2", data_file: nil, status: true, category: "Other")
      end

      it "returns the latest other dataset" do
        get "/data_sets/latest/other", headers: headers, params: params
        expect(response.body).to eq('other3,other4')
      end

      it "returns the StaffDirectoryRemoved dataset" do
        get "/data_sets/latest/staff-directory-removed", headers: headers, params: params
        expect(response.body).to eq('abc123,def456')
      end

      it "returns the data in a file for StaffDirectory" do
        Tempfile.create do |file|
          file.write("data from file\nMultiple lines")
          file.rewind
          DataSet.create(report_time: today, data: nil, data_file: file.path, status: true, category: "StaffDirectory")
          get "/data_sets/latest/staff-directory", headers: headers, params: params
          expect(response.body).to eq("data from file\nMultiple lines")
        end
      end
    end

    context "when the client is authenticated via cas" do
      let(:user) do
        User.create(email: 'user@localhost')
      end

      before do
        sign_in user
        DataSet.create(report_time: today_end_of_hour, data: "abc123,def456", data_file: nil, status: true, category: "StaffDirectoryRemoved")
        DataSet.create(report_time: today_end_of_hour, data: "other5,other6", data_file: nil, status: false, category: "Other")
        DataSet.create(report_time: today, data: "other3,other4", data_file: nil, status: true, category: "Other")
        DataSet.create(report_time: previous_time, data: "other1,other2", data_file: nil, status: true, category: "Other")
      end

      it "returns the latest other dataset" do
        get "/data_sets/latest/other"
        expect(response.body).to eq('other3,other4')
      end
    end
  end
end
