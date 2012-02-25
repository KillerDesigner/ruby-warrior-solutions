require "spec_helper"

def make_space
  space = double(Object).extend EntityMethods
  space.stub(:empty?) { true }
  space
end

class Warrior
  include WarriorMethods
  include EntityMethods
end

class Enemy
  include EntityMethods
end

describe "RubyWarrior" do
  before do
    @warrior = double(Warrior)
    @warrior.extend WarriorMethods
    @warrior.extend EntityMethods
    @warrior.extend TestOnlyMethods
    @warrior.extend GameLogic

    @warrior.health = @warrior.max_health = @warrior.last_health = 20
  end

  describe Warrior do
    subject { @warrior }

    context "when wounded" do
      before do
        @warrior.wound
      end

      context "and taking damage" do
        before do
          @warrior.ahead = make_space
        end

        context "and taking damage" do
          it "should charge into danger" do
            @warrior.should_receive :walk!
            @warrior.take_action
          end
        end
      end

      context "and not alone" do
        before do
          @warrior.ahead = Object.new.extend(EntityMethods).extend(TestOnlyMethods)
          @warrior.feel.health = 5
        end

        it "should attack instead of resting" do
          @warrior.should_receive(:attack!)
          @warrior.should_not_receive(:nap!)
          @warrior.take_action
        end
      end
    end

    context "when facing nothing" do
      before do
        @warrior.ahead = make_space
      end

      it "should walk" do
        @warrior.should_receive :walk!
        @warrior.take_action
      end
    end

    context "when facing an enemy" do
      before do
        @enemy = double(Enemy).extend(EntityMethods).extend(TestOnlyMethods)
        @enemy.health = @enemy.max_health = 20
        @warrior.ahead = @enemy
      end

      it "have at it!" do
        @enemy.should_not be_wounded
        @warrior.take_action
        @enemy.should be_wounded
      end
    end
  end

end
