require 'rails_helper'

RSpec.describe Scheduling::Resolver do
  let(:current) { "2017-12-10 10:00 UTC" }
  before { Timecop.freeze(current) }
  after  { Timecop.return }

  describe "#perform" do
    subject { described_class.new(ride_at) }

    let(:ride_at)     { Time.parse("2017-12-10 11:06 UTC") }
    let(:middle_time) { Time.parse("2017-12-10 10:03 UTC") }

    before { allow(subject).to receive(:occupied_slots).and_return(occupied_slots) }

    context "when there are no occupied slots" do
      let(:occupied_slots) { [] }

      it "returns start_at as a middle value in the timeline" do
        expect(subject.perform).to eq(middle_time)
      end
    end

    context "when there are one occupied slot at the middle of timeline" do
      let(:occupied_slots) { [middle_time.to_i] }

      it "returns start_at as a previous value to the middle" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:02 UTC"))
      end
    end

    context "when there are two occupied slots" do
      let(:occupied_slots) { [middle_time.to_i, Time.parse("2017-12-10 10:02 UTC").to_i] }

      it "returns start_at as a next value to the middle" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:04 UTC"))
      end
    end

    context "when there are occupied slots not around the middle of timeline" do
      let(:occupied_slots) do
        [
          Time.parse("2017-12-10 10:00:00 UTC").to_i,
          Time.parse("2017-12-10 10:01:30 UTC").to_i,
          Time.parse("2017-12-10 10:02:00 UTC").to_i,
          Time.parse("2017-12-10 10:03:30 UTC").to_i,
          Time.parse("2017-12-10 10:05:00 UTC").to_i
        ]
      end

      it "returns the middle start_at" do
        expect(subject.perform).to eq(middle_time)
      end
    end

    context "when all but earliest of the default slots are occupied" do
      let(:occupied_slots) do
        [
          Time.parse("2017-12-10 10:01:00 UTC").to_i,
          Time.parse("2017-12-10 10:02:00 UTC").to_i,
          middle_time.to_i,
          Time.parse("2017-12-10 10:04:00 UTC").to_i,
          Time.parse("2017-12-10 10:05:00 UTC").to_i,
          Time.parse("2017-12-10 10:06:00 UTC").to_i
        ]
      end

      it "returns earliest start_at" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:00:00 UTC"))
      end
    end

    context "when all but latest of the default slots are occupied" do
      let(:occupied_slots) do
        [
          Time.parse("2017-12-10 10:00:00 UTC").to_i,
          Time.parse("2017-12-10 10:01:00 UTC").to_i,
          Time.parse("2017-12-10 10:02:00 UTC").to_i,
          middle_time.to_i,
          Time.parse("2017-12-10 10:04:00 UTC").to_i,
          Time.parse("2017-12-10 10:05:00 UTC").to_i
        ]
      end

      it "returns earliest start_at" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:06:00 UTC"))
      end
    end

    context "when all of the default slots are occupied" do
      let(:occupied_slots) do
        [
          Time.parse("2017-12-10 10:00:00 UTC").to_i,
          Time.parse("2017-12-10 10:01:00 UTC").to_i,
          Time.parse("2017-12-10 10:02:00 UTC").to_i,
          middle_time.to_i,
          Time.parse("2017-12-10 10:04:00 UTC").to_i,
          Time.parse("2017-12-10 10:05:00 UTC").to_i,
          Time.parse("2017-12-10 10:06:00 UTC").to_i
        ]
      end

      it "divides the step by 2" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:02:30 UTC"))
      end
    end

    context "when all of the default slots are occupied" do
      let(:occupied_slots) do
        [
          Time.parse("2017-12-10 10:00:00 UTC").to_i,
          Time.parse("2017-12-10 10:00:30 UTC").to_i,
          Time.parse("2017-12-10 10:01:00 UTC").to_i,
          Time.parse("2017-12-10 10:01:30 UTC").to_i,
          Time.parse("2017-12-10 10:02:00 UTC").to_i,
          Time.parse("2017-12-10 10:02:30 UTC").to_i,
          middle_time.to_i,
          Time.parse("2017-12-10 10:03:30 UTC").to_i,
          Time.parse("2017-12-10 10:04:00 UTC").to_i,
          Time.parse("2017-12-10 10:04:30 UTC").to_i,
          Time.parse("2017-12-10 10:05:00 UTC").to_i,
          Time.parse("2017-12-10 10:05:30 UTC").to_i,
          Time.parse("2017-12-10 10:06:00 UTC").to_i
        ]
      end

      it "divides the step by 4" do
        expect(subject.perform).to eq(Time.parse("2017-12-10 10:02:45 UTC"))
      end
    end

    describe 'active hours' do
      let(:occupied_slots) { [] }

      context 'when it is the same night' do
        let(:ride_at) { Time.parse("2017-12-10 23:40:00 UTC") }

        context 'when request came at morning' do
          it "schedules on the same day" do
            expect(subject.perform).to eq(Time.parse("2017-12-10 16:20 UTC"))
          end
        end

        context 'when request came at evening' do
          let(:current) { "2017-12-10 21:00 UTC" }

          it "schedules on the same day" do
            expect(subject.perform).to eq(Time.parse("2017-12-10 21:50 UTC"))
          end
        end

        context 'when request came at late evening' do
          let(:current) { "2017-12-10 22:10 UTC" }

          it "schedules on the same day" do
            expect(subject.perform).to eq(Time.parse("2017-12-10 22:25 UTC"))
          end
        end
      end

      context 'when it is the same day' do
        let(:ride_at) { Time.parse("2017-12-10 20:40:00 UTC") }

        context 'when request came at morning' do
          it "schedules on the same day" do
            expect(subject.perform).to eq(Time.parse("2017-12-10 14:50 UTC"))
          end
        end

        context 'when request came at evening' do
          let(:current) { "2017-12-10 19:00 UTC" }

          it "schedules on the same day" do
            expect(subject.perform).to eq(Time.parse("2017-12-10 19:20 UTC"))
          end
        end
      end

      context 'when it is the next night' do
        let(:ride_at) { Time.parse("2017-12-11 23:40:00 UTC") }

        context 'when request came at morning' do
          it "schedules on the next day on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-11 15:00 UTC"))
          end
        end

        context 'when request came at evening' do
          let(:current) { "2017-12-10 21:00 UTC" }

          it "schedules on the next day starting on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-11 15:00 UTC"))
          end
        end
      end

      context 'when it is the next day' do
        let(:ride_at) { Time.parse("2017-12-11 15:00:00 UTC") }

        context 'when request came at morning' do
          it "schedules on the next day on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-11 11:00 UTC"))
          end
        end

        context 'when request came at evening' do
          let(:current) { "2017-12-10 21:00 UTC" }

          it "schedules on the next day starting on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-11 11:00 UTC"))
          end
        end
      end

      context 'when it is the day after tomorrow' do
        let(:ride_at) { Time.parse("2017-12-12 15:00:00 UTC") }

        context 'when request came at morning' do
          it "schedules on the day after tomorrow on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-12 11:00 UTC"))
          end
        end

        context 'when request came at evening' do
          let(:current) { "2017-12-10 21:00 UTC" }

          it "schedules on the day after tomorrow starting on active hours" do
            expect(subject.perform).to eq(Time.parse("2017-12-12 11:00 UTC"))
          end
        end
      end
    end

    # this shouldn't be here, it's just a snippet for benchmarking
    describe "performance" do
      # iterating over 1000 occupied slots to find an available one takes 0.6 ms on my local machine
      # note: database query is stubbed, of course
      context "when 1000 occupied slots iterated" do
        let(:ride_at) { Time.parse("2017-12-11 03:40:00 UTC") }
        let(:occupied_slots) do
          slots = []
          init  = Time.parse("2017-12-10 10:00:00 UTC")
          1000.times { |n| slots << (init + n.minutes).to_i }
          slots
        end

        it do
          # Benchmark.measure { subject.perform }
          expect(subject.perform).to eq(Time.parse("2017-12-11 02:40 UTC"))
        end
      end
    end
  end
end
