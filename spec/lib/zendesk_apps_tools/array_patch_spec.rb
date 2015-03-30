require 'spec_helper'
require 'zendesk_apps_tools/array_patch'

describe Array do
  describe '#to_h' do
    subject { [[1,2], [3,4]] }

    it 'works' do
      expect(subject.to_h).to eq({ 1 => 2, 3 => 4 })
    end

    context 'when it has non array element' do
      subject { [1,2,3] }

      it 'raises TypeError' do
        expect { subject.to_h }.to raise_error(TypeError)
      end
    end

    context 'when it has element arrays with wrong size' do
      subject { [[1,2,3]] }

      it 'raises ArgumentError' do
        expect { subject.to_h }.to raise_error(ArgumentError)
      end
    end
  end
end
