require_relative '../../models/models'

RSpec.describe Journey do
  let(:journey) do
    described_class.new('1')
  end
  let(:first_flexi_alternative) { create_alternative('flexi', 'First', 100) }
  let(:first_nonflexi_alternative) { create_alternative('nonflexi', 'First', 100) }
  let(:standard_flexi_alternative) { create_alternative('flexi', 'Standard', 100) }
  let(:standard_nonflexi_alternative) { create_alternative('nonflexi', 'Standard', 100) }

  before do
    journey.sections = sections
    journey.depart_at_str = '2021-07-01T10:00:00'
    journey.arrive_at_str = '2021-07-01T15:00:00'
    journey.service_agencies = ['DB']
    journey.departure_location = 'Berlin'
    journey.arrival_location = 'Munich'
  end

  describe '#available_classes' do
    subject { journey.available_classes }

    context 'when all sections have standard class' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [standard_flexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [standard_flexi_alternative] }
        ]
      end

      it { is_expected.to eq(['Standard']) }
    end

    context 'when some sections have first class' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [first_flexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [first_flexi_alternative] }
        ]
      end

      it { is_expected.to eq(['First']) }
    end

    context 'when all sections have all class' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [first_flexi_alternative, standard_flexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [standard_flexi_alternative] }
        ]
      end

      it { is_expected.to eq(%w[Standard First]) }
    end

    context 'only one section has standard class' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [first_flexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [standard_flexi_alternative] }
        ]
      end

      it { is_expected.to eq(%w[First]) }
    end
  end

  describe '#available_flexibilities' do
    subject { journey.available_flexibilities }

    context 'returns all flexibilities of the journey' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [first_flexi_alternative, standard_nonflexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [standard_nonflexi_alternative] }
        ]
      end

      it { is_expected.to eq(%w[flexi nonflexi]) }
    end
  end

  describe '#as_json' do
    subject { journey.as_json }

    context 'returns journey as json' do
      let(:sections) do
        [
          Section.new('1').tap { |s| s.alternatives = [first_flexi_alternative, standard_nonflexi_alternative] },
          Section.new('2').tap { |s| s.alternatives = [first_flexi_alternative, standard_nonflexi_alternative] }
        ]
      end

      it do
        is_expected.to eq(
          {
            departure_station: 'Berlin',
            departure_at: DateTime.parse('2021-07-01T10:00:00'),
            arrival_station: 'Munich',
            arrival_at: DateTime.parse('2021-07-01T15:00:00'),
            service_agencies: ['DB'],
            duration_in_minutes: 300,
            changeovers: nil,
            products: ['train'],
            fares: [
              {
                name: 'Super',
                price_in_cents: 20000,
                currency: 'EUR',
                comfort_class: 'Standard'
              },
              {
                name: 'Super',
                price_in_cents: 20000,
                currency: 'EUR',
                comfort_class: 'First'
              }
            ]
          }
        )
      end
    end
  end

  private

  def create_alternative(flexi, class_name, price, mode = 'train')
    Alternative.new('1').tap do |a|
      a.flexibility = flexi
      a.class_name = class_name
      a.currency = 'EUR'
      a.price = price || 100
      a.name = 'Super'
      a.mode = mode
    end
  end
end