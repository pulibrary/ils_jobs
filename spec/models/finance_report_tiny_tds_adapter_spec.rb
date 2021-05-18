# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FinanceReportTinyTdsAdapter, type: :model do
  subject(:tiny_tds_adapter) do
    described_class.new(
      dbhost: dbhost,
      dbport: dbport,
      dbuser: dbuser,
      dbpass: dbpass
    )
  end
  let(:dbhost) { 'localhost' }
  let(:dbport) { 23 }
  let(:dbuser) { 'user' }
  let(:dbpass) { 'secret' }

  describe '#execute' do
    let(:query) do
      "SELECT * FROM Staff"
    end
    let(:client) { instance_double(TinyTds::Client) }

    before do
      allow(client).to receive(:execute).and_return([])
    end

    it 'executes the query using the database client' do
      allow(TinyTds::Client).to receive(:new).and_return(client)
      tiny_tds_adapter.execute(query: query)
      expect(client).to have_received(:execute).with(query)
    end

    context 'when an error is raised' do
      let(:logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(logger).to receive(:error)
        allow(Rails).to receive(:logger).and_return(logger)
        allow(TinyTds::Client).to receive(:new).and_raise(TinyTds::Error, 'error message')
      end

      it 'logs the error' do
        tiny_tds_adapter.execute(query: query)
        expect(logger).to have_received(:error).with('Failed to connect to the financial report server: error message')
      end
    end
  end

  describe '#execute_staff_query' do
    let(:employee_id) { 'testuser' }
    let(:query) do
      "SELECT * FROM Staff Join Staff2Positions on Staff.idStaff = Staff2Positions.idStaff " \
      "join Positions on Staff2Positions.idPosition = Positions.idPosition " \
      "FULL OUTER join [Units extensions] on Positions.idUnit = [Units extensions].idUnit " \
      "join JobCodes on Positions.JobCode = JobCodes.JobCode " \
      "join [Work units] on Positions.idUnit = [Work units].idUnit " \
      "join Building on Positions.idBuilding = Building.ID_Building " \
      "where PUID = 'testuser' and EndDate is null"
    end
    let(:client) { instance_double(TinyTds::Client) }

    before do
      allow(client).to receive(:execute).and_return([])
      allow(TinyTds::Client).to receive(:new).and_return(client)

      tiny_tds_adapter.execute_staff_query(employee_id: employee_id)
    end

    it 'executes the query using the database client' do
      expect(client).to have_received(:execute).with(query)
    end
  end
end
