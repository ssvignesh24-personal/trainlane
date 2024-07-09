require_relative '../../models/models'
require_relative '../../services/journey_service'
require_relative '../../trainline_api/result'

RSpec.describe JourneyService do
  let(:service) do
    described_class.call(journey_id, result)
  end
  let(:journey_id) { '1' }
  let(:result) { TrainlineApi::Result.new(body) }
  let(:body) { File.read('spec/fixtures/sample.json') }

  context 'when journey is found' do
    let(:journey) { service.build_journey }

    it 'builds a journey' do
      expect(journey).to be_a(Journey)
    end

    it 'sets the sections' do
      expect(journey.sections.size).to eq(1)
    end

    it 'sets the correct alternatives' do
      expect(journey.sections.first.alternatives.size).to eq(2)
    end

    it 'sets the correct location' do
      expect(journey.departure_location).to eq('Berlin Hbf (tief)')
      expect(journey.arrival_location).to eq('Paris Gare de l’Est')
    end

    it 'sets the correct changeovers' do
      expect(journey.changeovers).to eq(1)
    end
  end

  context 'when journey is found but without sections' do
    let(:body) { File.read('spec/fixtures/without_sections.json') }

    it 'returns nil' do
      expect(service).to be(nil)
    end
  end

  context 'when journey is not found' do
    let(:journey_id) { '2' }

    it 'returns nil' do
      expect(service).to be(nil)
    end
  end
end