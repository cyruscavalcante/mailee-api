#INSERT INTO "unsubscribes" ("created_at", "contact_id", "reason", "spam", "message_id") VALUES('2010-10-05 22:52:25.657597', 2082562, default, 'f', default) RETURNING "id"

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mailee" do

  before(:each) do
    Mailee::Config.site = "http://api.bdb28c0a0a4a3.softa.server:3000"
    @moment = Time.now.strftime('%Y%m%d%H%M%S')
  end
  
  it "should import (quick)" do
    result = Mailee::Quick.create :contacts => "rest_test_#{@moment}@test.com\nrest_test_2_#{@moment}@test.com\nrest_test_3_#{@moment}@test.com"
    result.should
  end
  
  it "should have appropriate classes" do
    Mailee.should
    Mailee::Config.should
    Mailee::Contact.should
    Mailee::List.should
    Mailee::Quick.should
    Mailee::Message.should
    Mailee::Template.should
    Mailee::Report.should
  end

  it "should get first contact" do
    contact = Mailee::Contact.first
    contact.id.should
  end
  
  it "should create contact" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.id.should
  end

  it "should get all contacts" do
    Array.new(25){|i| Mailee::Contact.create :email => "rest_test_#{@moment}_#{i}@test.com"}
    contacts = Mailee::Contact.find(:all)
    contacts.size.should be(15)
    contacts = Mailee::Contact.find(:all, :params => {:page => 2, :by_keyword => "rest_test_#{@moment}" })
    contacts.size.should be(10)
  end

  it "should create contact - and find by id" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.id.should
    found_contact = Mailee::Contact.find(contact.id)
    found_contact.id.should be(contact.id)
  end

  it "should create contact - and find by internal_id" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com", :internal_id => @moment
    contact.id.should
    contact.internal_id.should == @moment
    contact = Mailee::Contact.find(:first, :params => { :internal_id => @moment })
    contact.internal_id.should == @moment
  end

  it "should create contact - with dynamic attributes" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com", :dynamic_attributes => {:foo => 'bar'}
    contact.id.should
    contact.dynamic_attributes.attributes['foo'].should == 'bar'
  end

  it "should create list - and find by id" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    list.id.should
    list = Mailee::List.find(list.id)
    list.id.should
  end

  it "should create contact - and subscribe" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.put(:subscribe, :list => "rest_test_#{@moment}").should
  end

  it "should create contact - and unsubscribe" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.put(:unsubscribe).should
  end

  it "should create message" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    message = Mailee::Message.create :title => "rest_test_#{@moment}", :subject => "rest_test_#{@moment}", :from_name => "rest_test_#{@moment}", :from_email => "rest_test_#{@moment}@test.com", :html => "rest_test_#{@moment}", :list_id => list.id
    message.id.should
  end

  it "should create message - with emails" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    message = Mailee::Message.create :title => "rest_test_#{@moment}", :subject => "rest_test_#{@moment}", :from_name => "rest_test_#{@moment}", :from_email => "rest_test_#{@moment}@test.com", :html => "rest_test_#{@moment}", :emails => 'foo@bar.com bar@foo.com'
    #raise message.inspect
    message.id.should
  end

  it "should create, test and send message" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.put(:subscribe, :list => list.name)
    message = Mailee::Message.create :title => "rest_test_#{@moment}", :subject => "rest_test_#{@moment}", :from_name => "rest_test_#{@moment}", :from_email => "rest_test_#{@moment}@test.com", :html => "rest_test_#{@moment}", :list_id => list.id
    message.put(:test, :contacts => [contact.id]).should
    message.put(:ready, :when => 'now').should
  end

  # API specific methods

  it "should create, subscribe and unsubscribe a contact" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.subscribe("rest_test_#{@moment}").should
    contact.unsubscribe.should
  end

  it "should search contacts" do
    Mailee::Contact.search("rest_test").should
  end

  it "should create and find by internal id" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com", :internal_id => @moment
    found = Mailee::Contact.find_by_internal_id(@moment)
    found.id.should be(contact.id)
  end

  it "should create and find by email" do
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    found = Mailee::Contact.find_by_email("rest_test_#{@moment}@test.com")
    found.id.should be(contact.id)
  end

  it "should create, test and send message - specific methods" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.put(:subscribe, :list => list.name)
    message = Mailee::Message.create :title => "rest_test_#{@moment}", :subject => "rest_test_#{@moment}", :from_name => "rest_test_#{@moment}", :from_email => "rest_test_#{@moment}@test.com", :html => "rest_test_#{@moment}", :list_id => list.id
    message.test([contact.id]).should
    message.ready.should
  end

  it "should create, test and send after message - specific methods" do
    list = Mailee::List.create :name => "rest_test_#{@moment}"
    contact = Mailee::Contact.create :email => "rest_test_#{@moment}@test.com"
    contact.put(:subscribe, :list => list.name)
    message = Mailee::Message.create :title => "rest_test_#{@moment}", :subject => "rest_test_#{@moment}", :from_name => "rest_test_#{@moment}", :from_email => "rest_test_#{@moment}@test.com", :html => "rest_test_#{@moment}", :list_id => list.id
    message.test([contact.id]).should
    message.ready(10.days.from_now).should
  end

  it "should import (quick) - specific methods" do        Mailee::Quick.import("rest_test_#{@moment}@test.com\nrest_test_2_#{@moment}@test.com\nrest_test_3_#{@moment}@test.com").should
  end

end