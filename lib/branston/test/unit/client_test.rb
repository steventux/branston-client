require 'test_helper'
require "rexml/document"

class ClientTest < ActiveSupport::TestCase

  context "The Branston Client" do
    setup do
      @feature_file = FEATURE_PATH + 'product_search.feature'
      @step_file = FEATURE_PATH + '/step_definitions/product_search_steps.rb'
      @options = {
        :Port        => 3970,
        :Host        => "0.0.0.0",
        :feature     => 1
      }
      @client = Client.new @options
    end

    context "A complete story" do
      setup do
        mock_xml = File.new(RAILS_ROOT + "/test/xml/example.xml")
        @client.stubs(:get_xml).returns(REXML::Document.new mock_xml)
        @client.generate_story_files
      end

      should "generate a feature file that can be run by cucumber" do
        assert File.exists? @feature_file

        f = File.open(@feature_file, "r")
        begin
          assert_equal "Feature: Product Search\n", f.gets
          assert_equal "\tAs an actor\n", f.gets
          assert_equal "\tI should be able to search for products by title\n", f.gets
          f.gets #empty line
          assert_equal "\tScenario: I search for \"planes\"\n", f.gets
          assert_equal "\t\tGiven I search for \"planes\"\n", f.gets
          assert_equal "\t\t\tAnd \"planetoid\" is a fancy word for \"planet\"\n", f.gets
          assert_equal "\t\tThen A competition should appear\n", f.gets
          assert_equal "\n", f.gets
        ensure
          f.close
        end
      end

      should "generate a skeleton step definition file" do
        assert File.exists? @step_file
        f = File.open(@step_file, "r")
        begin
          assert_equal "Given /^I search for \"([^\\\"]*)\"$/ do |a|\n", f.gets
          assert_equal "\t#TODO: Define these steps\n", f.gets
          assert_equal "\tpending\n", f.gets
          assert_equal "end\n", f.gets
          assert_equal "\n", f.gets

          assert_equal "Given /^\"([^\\\"]*)\" is a fancy word for \"([^\\\"]*)\"$/ do |a, b|\n", f.gets
          assert_equal "\t#TODO: Define these steps\n", f.gets
          assert_equal "\tpending\n", f.gets
          assert_equal "end\n", f.gets
          assert_equal "\n", f.gets

          assert_equal "Then /^A competition should appear$/ do\n", f.gets
          assert_equal "\t#TODO: Define these steps\n", f.gets
          assert_equal "\tpending\n", f.gets
          assert_equal "end\n", f.gets
          assert_equal "\n", f.gets

          assert_equal "\n", f.gets
        ensure
          f.close
        end
      end
    end

    context "A story without scenarios" do
      setup do
        mock_xml = File.new(RAILS_ROOT + "/test/xml/no_scenarios.xml")
        @client.stubs(:get_xml).returns(REXML::Document.new mock_xml)
        @client.generate_story_files
      end

      should "generate just the story outline and an empty step file" do
        assert File.exists? @feature_file
        assert File.exists? @step_file

        f = File.open(@feature_file, "r")
        begin
          assert_equal "Feature: Product Search\n", f.gets
          assert_equal "\tAs an actor\n", f.gets
          assert_equal "\tI should be able to search for products by title\n", f.gets
          f.gets #empty line
        ensure
          f.close
        end
      end
    end

    context "The get_xml method" do
      should "fail gracefully" do
        assert_raise Errno::ECONNREFUSED do
          @client.get_xml
          assert_equal ["Could not connect to Branston server on 0.0.0.0:3970: " +
            "Connection refused - connect(2)\nIs Branston running?"], @client.errors
        end
      end

      should "work, don't worry about it" do
        Net::HTTP.stubs(:start).returns(true)
        @client.get_xml
      end
    end

    context "The process_xml method" do
      should "fail gracefully" do
        @client.process_xml nil
        assert_equal ["Did not recieve XML data for story 1.\nIs the Branston " +
          "server running, and have you provided the correct story name?"], @client.errors
        @client.process_xml REXML::Document.new
        assert_equal ["Did not recieve XML data for story 1.\nIs the Branston " +
          "server running, and have you provided the correct story name?"], @client.errors

        @client.process_xml REXML::Document.new.add_element 'story'
        assert_equal ["Could not generate feature: undefined method `text' for " +
          "nil:NilClass"], @client.errors
      end
    end

  end
end

