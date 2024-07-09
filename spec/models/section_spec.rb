require_relative '../../models/models'

RSpec.describe Section do
  let(:section) do
    described_class.new('1')
  end
  let(:first_flexi_alternative) { create_alternative('flexi', 'First', 100) }
  let(:first_nonflexi_alternative) { create_alternative('nonflexi', 'First', 200) }
  let(:standard_flexi_alternative) { create_alternative('flexi', 'Standard', 300) }
  let(:standard_nonflexi_alternative) { create_alternative('nonflexi', 'Standard', 400) }
  let(:standard_semiflexi_alternative_bus) { create_alternative('semiflexi', 'Standard', 500, 'bus') }

  before do
    section.alternatives = alternatives
  end

  describe '#available_classes' do
    subject { section.available_classes }

    context 'when all alternatives have standard class' do
      let(:alternatives) do
        [standard_flexi_alternative, standard_nonflexi_alternative]
      end

      it { is_expected.to eq(['Standard']) }
    end

    context 'when some alternatives have first class' do
      let(:alternatives) do
        [first_flexi_alternative, first_nonflexi_alternative]
      end

      it { is_expected.to eq(['First']) }
    end

    context 'when all alternatives have all class' do
      let(:alternatives) do
        [first_flexi_alternative, standard_flexi_alternative]
      end

      it { is_expected.to eq(%w[First Standard]) }
    end
  end

  describe '#available_flexibilities' do
    subject { section.available_flexibilities }

    context 'returns all flexibilities of the section' do
      let(:alternatives) do
        [first_flexi_alternative, standard_nonflexi_alternative, standard_flexi_alternative, first_nonflexi_alternative]
      end

      it { is_expected.to eq(%w[flexi nonflexi]) }
    end
  end

  describe '#has_standard_class?' do
    subject { section.has_standard_class? }

    context 'when atleast one alternative has standard class' do
      let(:alternatives) do
        [standard_flexi_alternative, first_nonflexi_alternative, first_flexi_alternative]
      end

      it { is_expected.to be true }
    end

    context 'when no alternative has standard class' do
      let(:alternatives) do
        [first_nonflexi_alternative, first_flexi_alternative]
      end

      it { is_expected.to be false }
    end
  end

  describe '#has_first_class?' do
    subject { section.has_first_class? }

    context 'when atleast one alternative has first class' do
      let(:alternatives) do
        [standard_flexi_alternative, first_nonflexi_alternative, first_flexi_alternative]
      end

      it { is_expected.to be true }
    end

    context 'when no alternative has first class' do
      let(:alternatives) do
        [standard_flexi_alternative, standard_nonflexi_alternative]
      end

      it { is_expected.to be false }
    end
  end

  describe '#modes' do
    subject { section.modes }

    context 'when all alternatives are train' do
      let(:alternatives) do
        [standard_flexi_alternative, first_nonflexi_alternative, first_flexi_alternative]
      end

      it 'returns only train' do
        is_expected.to eq(['train'])
      end
    end

    context 'when alternatives has both modes' do
      let(:alternatives) do
        [standard_flexi_alternative, standard_semiflexi_alternative_bus]
      end

      it 'returns train and bus' do
        is_expected.to eq(%w[train bus])
      end
    end
  end

  describe '#price_of' do
    subject { section.price_of(class_name, flexibilities) }

    context 'when the passed class name and flexi are present' do
      let(:class_name) { 'First' }
      let(:flexibilities) { 'flexi' }
      let(:alternatives) do
        [standard_flexi_alternative, first_nonflexi_alternative, first_flexi_alternative]
      end

      it 'returns the correct price' do
        is_expected.to eq(100)
      end
    end

    context 'when the passed class name and flexi does not exists' do
      let(:class_name) { 'Standard' }
      let(:flexibilities) { 'flexi' }
      let(:alternatives) do
        [first_nonflexi_alternative, first_flexi_alternative]
      end

      it 'returns the correct price' do
        is_expected.to eq(0)
      end
    end

    context 'when the next class exists' do
      let(:class_name) { 'First' }
      let(:flexibilities) { 'flexi' }
      let(:alternatives) do
        [standard_flexi_alternative]
      end

      it 'returns the correct price' do
        is_expected.to eq(300)
      end
    end

    context 'when the next flexi exists' do
      let(:class_name) { 'First' }
      let(:flexibilities) { 'flexi' }
      let(:alternatives) do
        [first_nonflexi_alternative]
      end

      it 'returns the correct price' do
        is_expected.to eq(200)
      end
    end

    context 'when the alternative mode is bus' do
      let(:class_name) { 'First' }
      let(:flexibilities) { 'flexi' }
      let(:alternatives) do
        [standard_semiflexi_alternative_bus]
      end

      it 'return the bus cost' do
        is_expected.to eq(500)
      end
    end
  end

  describe '#name_of' do
    subject { section.name_of(class_name, flexibility) }

    context 'when the given class name and flexibility is found' do
      let(:class_name) { 'First' }
      let(:flexibility) { 'flexi' }
      let(:alternatives) do
        modified_first_flexi_alternative = first_flexi_alternative
        modified_first_flexi_alternative.name = 'Modified Super First flexi'
        [modified_first_flexi_alternative, first_flexi_alternative]
      end

      it 'returns the first name' do
        is_expected.to eq('Modified Super First flexi')
      end
    end

    context 'when the given class name and flexibility is not found' do
      let(:class_name) { 'Standard' }
      let(:flexibility) { 'flexi' }
      let(:alternatives) do
        [first_flexi_alternative]
      end

      it 'returns the first name' do
        is_expected.to eq(nil)
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
      a.name = "Super #{class_name} #{flexi}"
      a.mode = mode
    end
  end
end