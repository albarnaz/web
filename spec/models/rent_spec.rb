#encoding: UTF-8
require 'rails_helper'

RSpec.describe Rent, type: :model do
  let(:member) { create(:user, member_at: Time.zone.now) }
  let(:n_member) { create(:user, member_at: nil) }
  let(:council) { create(:council) }
  let(:new_rent) { build(:rent, user: member) }
  let(:new_rent_council) { build(:rent, user: member, council: council) }
  subject(:rent_n) { build(:rent, user: n_member) }
  let(:rent) { create(:rent, user: member) }
  let(:rent_council) { create(:rent, user: member, council: council) }

  describe 'has valid factory' do
    it { should be_valid }
  end

  describe :Associations do
    it { should belong_to(:profile) }
    it { should belong_to(:council) }
  end

  describe :Validations do
    # Disclaimer
    it { should allow_value(true).for(:disclaimer) }
    it { should_not allow_value(false).for(:disclaimer) }

    describe :RequiredAttributes do
      it { should validate_presence_of(:d_from) }
      it { should validate_presence_of(:d_til) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:lastname) }
      it { should validate_presence_of(:phone) }
      it { should validate_presence_of(:email) }
    end

    describe :Purpose do
      # TODO Must be fixed with new member thingy.
      context 'validate purpose when not a member' do
        it { rent_n.should validate_presence_of(:purpose) }
        it { rent.should_not validate_presence_of(:purpose) }
      end
      context 'do not validate purpose when there is a profile' do
        before { allow(subject).to receive(:no_profile?).and_return(false) }
        it { should_not validate_presence_of(:purpose) }
      end
    end

    # Some tests for the duration method
    # /d.wessman
    describe :Duration do
      context :when_no_council do
        it 'add error if duration is over 48' do
          rent = build(:rent, :over_48)
          rent.should_not be_valid
          rent.errors.get(:d_from).should include(I18n.t('rent.validation.duration'))
        end
        it 'do not add error if duration is under 48' do
          rent = build(:rent, :under_48)
          rent.should be_valid
        end
      end
      context :when_council do
        it 'do not add error if duration is over 48' do
          rent = build(:rent, :over_48, :with_council)
          rent.should be_valid
        end
      end
    end

    # Test to make sure rent is in future
    # /d.wessman
    describe :Dates_in_future do
      context :when_future do
        it 'add error if d_from > d_til' do
          new_rent.d_from = new_rent.d_til + 1.hour
          new_rent.should_not be_valid
          new_rent.errors.get(:d_til).should include(I18n.t('rent.validation.ascending'))
        end
      end
      context :when_past do
        it 'add error if d_from > d_til' do
          new_rent.d_til = Time.zone.now - 10.hours
          new_rent.d_from = new_rent.d_til + 5.hours
          new_rent.should_not be_valid
          new_rent.errors.get(:d_from).should include(I18n.t('rent.validation.future'))
        end
        it 'add error if d_from < d_til' do
          new_rent.d_from = Time.zone.now - 10.hours
          new_rent.d_til = new_rent.d_from + 5.hours
          new_rent.should_not be_valid
          new_rent.errors.get(:d_from).should include(I18n.t('rent.validation.future'))
        end
      end
    end



    # Validate if overlap
    # /d.wessman
    describe :Overlap do
      # The times mark offset from:
      # new.from = saved.from + offset
      # new.from = saved.til + offset
      # new.til = saved.from + offset
      # new.til = saved.til + offset
      overlap = {
        end: [-5, 0, 0, -5],
        from: [5, 0, 0, 5],
        both: [5, 0, 0, -5],
        none: [-5, 0, 0, 5],
        after: [0, 5, 0, 5]
      }

      context 'no councils' do
        b = { end: false, from: false, both: false, none: false, after: true }
        let(:new) { new_rent }
        let(:saved) { rent }
        overlap.each do |key, value|
          it %(#{key} should be #{b[key]}) do
            new.d_from = saved.d_from + value[0] unless value[0] == 0
            new.d_from = saved.d_til + value[1] unless value[1] == 0
            new.d_til = saved.d_til + value[2] unless value[2] == 0
            new.d_til = saved.d_til + value[3] unless value[3] == 0

            new.valid?.should eq(b[key])
          end
        end
      end

      context 'new council' do
        let(:new) { new_rent_council }
        let(:saved) { rent }
        overlap.each do |key, value|
          it %(#{key} should be true) do
            new.d_from = saved.d_from + value[0] unless value[0] == 0
            new.d_from = saved.d_til + value[1] unless value[1] == 0
            new.d_til = saved.d_til + value[2] unless value[2] == 0
            new.d_til = saved.d_til + value[3] unless value[3] == 0

            new.valid?.should eq(true)
          end
        end
      end

      context 'saved council' do
        b = { end: false, from: false, both: false, none: false, after: true }
        let(:new) { new_rent }
        let(:saved) { rent_council }
        overlap.each do |key, value|
          it %(#{key} should be #{b[key]}) do
            new.d_from = saved.d_from + value[0] unless value[0] == 0
            new.d_from = saved.d_til + value[1] unless value[1] == 0
            new.d_til = saved.d_til + value[2] unless value[2] == 0
            new.d_til = saved.d_til + value[3] unless value[3] == 0

            new.valid?.should eq(b[key])
          end
        end
      end

      context 'both council' do
        b = { end: false, from: false, both: false, none: false, after: true }
        let(:new) { new_rent_council }
        let(:saved) { rent_council }
        overlap.each do |key, value|
          it %(#{key} should be #{b[key]}) do
            new.d_from = saved.d_from + value[0] unless value[0] == 0
            new.d_from = saved.d_til + value[1] unless value[1] == 0
            new.d_til = saved.d_til + value[2] unless value[2] == 0
            new.d_til = saved.d_til + value[3] unless value[3] == 0

            new.valid?.should eq(b[key])
          end
        end
      end
    end

    # This tests makes sure that dates are formatted into ISO8601 for
    # Fullcalendars json-feed
    # Ref.: https://github.com/fsek/web/issues/99
    # /d.wessman
    describe :Json do
      it 'check date format is iso8601' do
        (rent.as_json.to_json).should include(rent.d_from.iso8601.to_json)
        (rent.as_json.to_json).should include(rent.d_til.iso8601.to_json)
      end
    end
  end
end
