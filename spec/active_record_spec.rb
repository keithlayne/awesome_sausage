require 'spec_helper'

describe AwesomeSausage::ActiveRecord do

  describe 'inclusion in a class' do
    it 'raises TypeError when not a subclass of AR::Base' do
      expect do
        Class.new.send :include, AwesomeSausage::ActiveRecord
      end.to raise_exception(TypeError)
    end

    it 'does not raise TypeError when a subclass of AR::Base' do
      expect do
        Class.new(::ActiveRecord::Base).send :include, AwesomeSausage::ActiveRecord
      end.not_to raise_exception(TypeError)
    end
  end

  describe '::ClassMethods' do
    let(:model_class) do
      Class.new(::ActiveRecord::Base).send :include, AwesomeSausage::ActiveRecord
    end

    describe '#none' do
      it 'returns an ActiveRelation' do
        expect(model_class.none).to be_an ActiveRelation
      end

      it 'caches the result' do
        expect(model_class.none).to be model_class.none
      end
    end

    describe '#*' do
      it 'returns an instance of AS::Arel' do
        expect(model_class.*).to be_an AwesomeSausage::Arel
      end

      it 'caches the result' do
        expect(model_class.*).to be model_class.*
      end
    end

    describe '#make_if' do

    end

    describe '#count_if' do

    end

    describe '#sum_if' do

    end

    describe '#case_when' do

    end

    describe '#function' do

    end

    describe '#left_joins' do
      pending 'Not sure how to implement this ATM'
    end
  end
end
