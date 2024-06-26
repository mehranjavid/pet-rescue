require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::AdopterApplicationPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  context "context only action" do
    setup do
      @organization = ActsAsTenant.current_tenant
      @policy = -> {
        Organizations::AdopterApplicationPolicy.new(
          AdopterApplication, organization: @organization, user: @user
        )
      }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user is nil" do
        setup do
          @user = nil
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is adopter" do
        setup do
          @user = create(:adopter)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is activated staff" do
        setup do
          @user = create(:staff)
        end

        context "when organization context is a different organization" do
          setup do
            @organization = create(:organization)
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when organization context is user's organization" do
          should "return true" do
            assert_equal @action.call, true
          end
        end
      end

      context "when user is deactivated staff" do
        setup do
          @user = create(:staff, :deactivated)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is staff admin" do
        setup do
          @user = create(:staff_admin)
        end

        context "when organization context is a different organization" do
          setup do
            @organization = create(:organization)
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when organization context is user's organization" do
          should "return true" do
            assert_equal @action.call, true
          end
        end
      end
    end

    context "#index?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :index?, :manage?
      end
    end
  end

  context "existing record action" do
    setup do
      @adopter_application = create(:adopter_application)
      @policy = -> {
        Organizations::AdopterApplicationPolicy.new(
          @adopter_application, user: @user
        )
      }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user is nil" do
        setup do
          @user = nil
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is adopter" do
        setup do
          @user = create(:adopter)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is activated staff" do
        setup do
          @user = create(:staff)
        end

        context "when application belongs to a different organization" do
          setup do
            ActsAsTenant.with_tenant(create(:organization)) do
              @adopter_application = create(:adopter_application)
            end
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when application belongs to user's organization" do
          should "return true" do
            assert_equal @action.call, true
          end
        end
      end

      context "when user is deactivated staff" do
        setup do
          @user = create(:staff, :deactivated)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is staff admin" do
        setup do
          @user = create(:staff_admin)
        end

        context "when application belongs to a different organization" do
          setup do
            ActsAsTenant.with_tenant(create(:organization)) do
              @adopter_application = create(:adopter_application)
            end
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when application belongs to user's organization" do
          should "return true" do
            assert_equal @action.call, true
          end
        end
      end
    end

    context "#edit?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :edit?, :manage?
      end
    end

    context "#update?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :update?, :manage?
      end
    end
  end
end
