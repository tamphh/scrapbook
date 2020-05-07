### Test `after_commit` callback
```ruby
class Company < ActiveRecord::Base
  after_commit :create_welcome_notification, on: :create
 
  private
 
  def create_welcome_notification
    WelcomeNotificationCreator.perform_async(id)
  end
end
 
class WelcomeNotificationCreator
  include Sidekiq::Worker
 
  def perform(company_id)
    @company = Company.find(company_id)
    @company.notifications.create({ title: 'Welcome to Gusto!' })
  end
end

# rspec
# spec/models/company_spec.rb
require 'rails_helper'
 
RSpec.describe Company, type: :model do
  describe '#save' do
    subject { company.save }
    let(:company) { build(:company) }
 
    it 'schedules a WelcomeNotificationCreator job' do
      expect {
        subject
      }.to change{ WelcomeNotificationCreator.jobs.size }.by(1)
      last_job = WelcomeNotificationCreator.jobs.last          
      expect(last_job['args']).to eq([subject.id])
    end
  end
end
 
# spec/workers/welcome_notification_creator_spec.rb
require 'rails_helper'
 
RSpec.describe WelcomeNotificationCreator do
  subject { described_class.new.perform(company.id)}
  let(:company) { create(:company) }
 
  it 'creates a notification' do
    expect {
      subject
    }.to change(Notification, :count).by(1)
    expect(Notification.last.title).to eq('Welcome to Gusto!')
  end
end
```
source: 
- https://engineering.gusto.com/the-rails-callbacks-best-practices-used-at-gusto/
- https://mytrile.github.io/blog/2013/03/28/testing-after-commit-in-rspec/
