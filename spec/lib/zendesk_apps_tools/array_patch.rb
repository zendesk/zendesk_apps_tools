require_relative '../../spec_helper.rb'

describe Array do
  describe '#to_h' do
    subject { [[1,2], [3,4]] }

    it 'works' do
      expect(subject.to_h).to eq({ 1 => 2, 3 => 4 })
    end
  end
end
