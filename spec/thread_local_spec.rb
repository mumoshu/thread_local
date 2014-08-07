require 'spec_helper'

describe ThreadLocal do
  it 'has a version number' do
    expect(ThreadLocal::VERSION).not_to be nil
  end

  let(:initial_value) {
    1
  }

  subject {
    ThreadLocal.new(initial_value)
  }

  context 'the associated value are read at least once' do
    before(:each) do
      subject.get
    end

    it "holds the initial value" do
      expect(subject.get).to eq(initial_value)
    end

    it "holds object_id's of threads on which the ThreadLocal is created" do
      expect(subject.__threads_object_ids__).to include(Thread.current.object_id)
    end

    context 'deleted the value afterward' do
      before(:each) do
        subject.delete
      end

      it "thinks the value is set" do
        expect(subject.set?).to be_truthy
      end

      it "holds a `nil` for its value" do
        expect(subject.get).to be_nil
      end
    end
  end

  context 'multi-threaded' do
    before(:each) do
      Thread.abort_on_exception = true
      Thread.start do
        subject.set 2

        expect(subject.get).to eq(2)
      end.join
    end

    it 'holds values separately for the other thread' do
      expect(subject.get).to eq(initial_value)
    end
  end
end
