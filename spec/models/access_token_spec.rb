require 'spec_helper'

describe AccessToken do
  let(:access_token) { create :access_token }
  let(:repository) { create :repository }

  before do
    repository.access_tokens << access_token
    repository.save
  end

  context 'expired?' do
    it 'should not be expired when the expiration date is in the future' do
      expect(access_token.expired?).to be_falsy
    end

    it 'should be expired when the expiration date is in the past' do
      access_token.expiration = (-1).minutes.from_now
      expect(access_token.expired?).to be_truthy
    end
  end
end
