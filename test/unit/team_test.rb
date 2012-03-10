require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  
  should_strip_attributes :name
  
  context 'Associations' do
    should have_many :team_users
    should have_many(:users).through(:team_users)
  end
  
  [ 'foo', '123 4', 'A multiword name' ].each do |val|
    should allow_value(val).for :name
  end

  [ nil, '','   A   ', 'fo','a very tooooooooooooooooooooooooooooooooooooooooooooooo long name' ].each do |val|
    should_not allow_value(val).for :name
  end
  
  context 'team instance' do
    setup do
      @team = Factory :team
    end
    
    should 'have to_s' do
      assert_equal @team.name, @team.to_s
    end
    
  end
  
end