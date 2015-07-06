require 'spec_helper'

describe Key do

  it { have_db_column('user_id').of_type(:integer) }
  it { have_db_column('key').of_type(:text) }
  it { have_db_column('fingerprint').of_type(:string) }

  it { belong_to :user }
  it { strip_attribute :key }

  context 'creating a key' do
    let(:user){ create :user }
    before { stub_cp_keys }

    context 'that is valid' do
      subject do
        user.keys.create! \
          name: 'My valid-rsa key',
          key:  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDbOTVgBk3Ludz6f2C3AShBsCwdooY4sX3NEeP+531+J1cf333tWYx8hyK78srdrnWkN5RihgJTJHgvmprYyZZBFA6+Fr9hxaRu7YHCDl0JozEhnGHNSL2U0J/FanRM2aOnmNZRpDZ603Qr3o27UiPU7f7nIog0LwsNIMBmlLlaoQ== valid_key'
      end

      it 'have correct fingerprint' do
        expect(subject.fingerprint).to eq("3a70b4aeb44328389b8feafbe3aeb9d8")
      end
      it 'have correct shell_id' do
        expect(subject.shell_id).to eq("key-#{subject.id}")
      end
    end

    context 'that is invalid' do
      subject do
        user.keys.create \
          name: 'My ecdsa key',
          key:  'ecdsa-sha2-nistp256 AAAAE2VjZtbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFoY047dBuHiWYi67TgKG0oKinCH0cNgJZu3lGIiUXCK0oXqktFrxeJjJnF9VG0ZLp+7tLl+mvmunNfBDVG9b7E= test@example'
      end

      it 'show correct error' do
        expect(subject.errors[:key]).to eq(["is not a public key file."])
      end
      it do
        expect(subject.fingerprint).to be(nil)
      end
    end
  end
end
