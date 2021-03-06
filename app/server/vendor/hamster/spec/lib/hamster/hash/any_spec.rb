require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:any?, :exist?, :exists?].each do |method|
    describe "##{method}" do
      context "when empty" do
        it "with a block returns false" do
          Hamster.hash.send(method) {}.should == false
        end

        it "with no block returns false" do
          Hamster.hash.send(method).should == false
        end
      end

      context "when not empty" do
        let(:hash) { Hamster.hash("A" => "aye", "B" => "bee", "C" => "see", nil => "NIL") }

        context "with a block" do
          [
            %w[A aye],
            %w[B bee],
            %w[C see],
            [nil, "NIL"],
          ].each do |pair|

            it "returns true if the block ever returns true (#{pair.inspect})" do
              hash.send(method) { |key, value| key == pair.first && value == pair.last }.should == true
            end

            it "returns false if the block always returns false" do
              hash.send(method) { |key, value| key == "D" && value == "dee" }.should == false
            end
          end

          it "propagates exceptions raised in the block" do
            -> { hash.any? { |k,v| raise "help" } }.should raise_error(RuntimeError)
          end

          it "stops iterating as soon as the block returns true" do
            yielded = []
            hash.any? { |k,v| yielded << k; true }
            yielded.size.should == 1
          end
        end

        context "with no block" do
          it "returns true" do
            hash.send(method).should == true
          end
        end
      end
    end
  end
end
