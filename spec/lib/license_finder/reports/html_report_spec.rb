require "spec_helper"
require "capybara"

module LicenseFinder
  describe HtmlReport do
    describe "#to_s" do
      let(:dependency) do
        dep = Dependency.create name: "the-name"
        dep.apply_better_license "MIT"
        dep
      end

      subject { Capybara.string(HtmlReport.new([dependency]).to_s) }

      context "when the dependency is manually approved" do
        before { dependency.approve! "the-approver", "the-approval-note" }

        it "should add an approved class to dependency's container" do
          should have_selector ".approved"
        end

        it "does not list the dependency in the action items" do
          should_not have_selector ".action-items"
        end

        it "shows the license, approver and approval notes" do
          deps = subject.find ".dependencies"
          deps.should have_content "MIT"
          deps.should have_content "the-approver"
          deps.should have_content "the-approval-note"
          deps.should have_selector "time"
        end
      end

      context "when the dependency is whitelisted" do
        before { dependency.stub(whitelisted?: true) }

        it "should add an approved class to dependency's container" do
          should have_selector ".approved"
        end

        it "does not list the dependency in the action items" do
          should_not have_selector ".action-items"
        end

        it "shows the license" do
          deps = subject.find ".dependencies"
          deps.should have_content "MIT"
        end
      end

      context "when the dependency is not approved" do
        before { dependency.manual_approval = nil }

        it "should not add an approved class to he dependency's container" do
          should have_selector ".unapproved"
        end

        it "lists the dependency in the action items" do
          should have_selector ".action-items li"
        end
      end

      context "when the gem has at least one bundler group" do
        before { dependency.stub(bundler_groups: [double(name: "group")]) }
        it "should show the bundler group(s) in parens" do
          should have_text "(group)"
        end
      end

      context "when the gem has no bundler groups" do
        before { dependency.stub(bundler_groups: []) }

        it "should not show any parens or bundler group info" do
          should_not have_text "()"
        end

      end

      context "when the gem has at least one parent" do
        before { dependency.stub(parents: [double(:name => "foo parent")]) }
        it "should include a parents section" do
          should have_text "Parents"
          should have_text "foo parent"
        end
      end

      context "when the gem has no parents" do
        it "should not include any parents section in the output" do
          should_not have_text "Parents"
        end
      end

      context "when the gem has at least one child" do
        before { dependency.stub(children: [double(:name => "foo child")]) }

        it "should include a Children section" do
          should have_text "Children"
          should have_text "foo child"
        end
      end

      context "when the gem has no children" do
        it "should not include any Children section in the output" do
          should_not have_text "Children"
        end
      end
    end
  end
end