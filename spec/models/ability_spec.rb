require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  let(:user){   create :user } # regular user
  let(:owner){  create :user } # owner

  context 'Repository' do
    let(:editor) { create :user } # editor
    let(:reader) { create :user } # reader
    let(:item) { create(:permission, subject: owner, role: 'owner').item }

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new, nil) }

      it 'not be allowed: new, create' do
        %i(new create).each do |perm|
          should_not be_able_to(perm, Repository.new)
        end
      end

      it 'be allowed: show' do
        should be_able_to(:show, Repository.new)
      end

      it 'not be allowed some actions' do
        %i(edit update destroy write).each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end

    context 'reader' do
      subject(:ability){ Ability.new(reader, nil) }

      it 'be allowed: new, create' do
        %i(new create).each do |perm|
          should be_able_to(perm, Repository.new)
        end
      end

      it 'not be allowed some actions' do
        %i(edit update destroy write).each do |perm|
          should_not be_able_to(perm, item)
        end
      end

      it 'be allowed: show' do
        should be_able_to(:show, create(:repository))
      end
    end

    context 'owner' do
      subject(:ability){ Ability.new(owner, nil) }

      it 'be allowed: new, create' do
        %i(new create).each do |perm|
          should be_able_to(perm, Repository.new)
        end
      end

      it 'be allowed: edit, update, destroy, permissions, write' do
        %i(show edit update destroy permissions).each do |perm|
          should be_able_to(perm, item)
        end
      end

      it 'not be allowed on other: edit, update, destroy, permissions' do
        %i(edit update destroy permissions).each do |perm|
          should_not be_able_to(perm, create(:repository))
        end
      end
    end

    context 'editor' do
      subject(:ability){ Ability.new(editor, nil) }

      it 'be allowed: write' do
        %i(show write).each do |perm|
          should be_able_to(perm, item)
        end
      end

      it 'not be allowed: edit, update, destroy, permissions' do
        %i(edit update destroy permissions).each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end
  end

  context 'Private Repository' do
    let(:editor){ create :user } # editor
    let(:reader){ create :user } # reader
    let!(:access_token) { create :access_token }
    let(:item) do
      repo = access_token.repository
      create(:permission, subject: owner, role: 'owner', item: repo)
      repo
    end

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new, nil) }

      it 'not be allowed: anything' do
        %i(show update write).each do |perm|
          should_not be_able_to(perm, item)
        end
      end

      context 'with access token' do
        subject(:ability){ Ability.new(User.new, access_token.to_s) }


        context 'not be allowed: change' do
          %i(update write).each do |perm|
            it "via #{perm}" do
              should_not be_able_to(perm, item)
            end
          end
        end

        it 'be allowed: read' do
          should be_able_to(:show, item)
        end
      end
    end

    context 'reader' do
      subject(:ability){ Ability.new(reader, nil) }

      it 'not be allowed: to manage' do
        %i(update write).each do |perm|
          should_not be_able_to(perm, item)
        end
      end

      it 'be allowed: to read' do
        should be_able_to(:show, item)
      end
    end

    context 'editor' do
      subject(:ability){ Ability.new(editor, nil) }

      it 'be allowed: to read and manage' do
        %i(show write).each do |perm|
          should be_able_to(perm, item)
        end
      end
    end

    context 'owner' do
      subject(:ability){ Ability.new(owner, nil) }

      it 'be allowed: everything' do
        %i(show update write).each do |perm|
          should be_able_to(perm, item)
        end
      end
    end
  end

  context 'Private Repository' do
    let(:editor) { create :user } # editor
    let(:reader) { create :user } # reader
    let(:item) { create(:repository, access: 'private_rw', user: owner) }

    before do
      create(:permission, subject: editor, role: 'editor', item: item)
      create(:permission, subject: reader, role: 'reader', item: item)
    end

    context 'guest' do
      subject(:ability){ Ability.new(User.new, nil) }

      it 'not be allowed: anything' do
        %i(show update write).each do |perm|
          should_not be_able_to(perm, item)
        end
      end
    end

    context 'reader' do
      it 'not be allowed: to write' do
        expect(Ability.new(reader, nil)).to_not be_able_to(:write, item)
      end

      it 'be allowed: to read' do
        expect(Ability.new(reader, nil)).to be_able_to(:show, item)
      end
    end

    context 'editor, owner' do
      it 'be allowed: to write' do
        [editor, owner].each do |role|
          expect(Ability.new(role, nil)).to be_able_to(:write, item)
        end
      end

      it 'be allowed: to read' do
        [editor, owner].each do |role|
          expect(Ability.new(role, nil)).to be_able_to(:show, item)
        end
      end
    end

    context 'update:' do
      it 'reader, editor should not be allowed' do
        [reader, editor].each do |role|
          expect(Ability.new(role, nil)).to_not be_able_to(:update, item)
        end
      end

      it 'owner should be allowed' do
        expect(Ability.new(owner, nil)).to be_able_to(:update, item)
      end
    end
  end

  context 'Team' do
    let(:other){ create :user }
    let(:memberteam){ create(:team_user, user: other).team }
    let(:otherteam){  create(:team_user, user: other).team }

    subject(:ability){ Ability.new(user, nil) }

    before { memberteam.users << user }

    context 'admin' do
      it 'be allowed: edit, update, destroy' do
        %i(edit update destroy).each do |perm|
          should be_able_to(perm, create(:team_user, user: user).team)
        end
      end
    end

    context 'member' do
      it 'be allowed: create, show, index' do
        %i(create show index).each do |perm|
          should be_able_to(perm, Team.new)
        end
      end

      it 'not be allowed: edit, update, destroy (without admin on team)' do
        %i(edit update destroy).each do |perm|
          should_not be_able_to(perm, @memberteam)
        end
      end

      it 'not be allowed: edit, update, destroy (without being on team)' do
        %i(edit update destroy).each do |perm|
          should_not be_able_to(perm, otherteam)
        end
      end
    end
  end

  context 'Comment' do
    let(:comment){ create :comment }

    context 'author' do
      subject(:ability){ Ability.new(comment.user, nil) }

      it 'destroy his own comment' do
        should be_able_to(:destroy, comment)
      end

      it 'not be allowed to destroy others comment' do
        should_not be_able_to(:destroy, create(:comment))
      end
    end

    context 'admin' do
      subject(:ability){ Ability.new(create(:admin), nil) }

      it 'destroy others comment' do
        should be_able_to(:destroy, comment)
      end
    end

    context 'comments repository owner' do
      subject(:ability){ Ability.new(owner, nil) }

      before do
        create(:permission, subject: owner, role: 'owner', item: comment.commentable.repository)
      end

      it 'destroy others comments for his repository' do
        should be_able_to(:destroy, comment)
      end
    end

    context 'comments repository editor' do
      subject(:ability){ Ability.new(owner, nil) }
      before do
        create(:permission, subject: owner, role: 'editor', item: comment.commentable.repository)
      end

      it 'not destroy others comments for his repository' do
        should_not be_able_to(:destroy, comment)
      end
    end
  end
end
