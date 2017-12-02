require 'rails_helper'

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe Companies::CompanyRegistration do
  describe '#approve_company' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let!(:company) do
      FactoryGirl.create(:company, id: 100, status: 'pending_registration')
    end
    let!(:company_person) do
      FactoryGirl.create(:pending_first_company_admin, company: company)
    end

    context 'when the company is approved with success' do
      before(:each) do
        TestTaskHelper.new_review_company_registration_task(company, agency)
        allow(Event).to receive(:create)
        allow(company.company_people[0].user).to receive(:send_confirmation_instructions)
        subject.approve_company(company)
      end

      it 'changes the state of the company to "approved"' do
        expect(Company.find(100).active?).to be(true)
      end

      it 'activate the company person' do
        company_people = Company.find(100).company_people
        expect(company_people.first.active?).to be(true)
        expect(company_people.first.approved).to be(true)
      end

      it 'create a "Company Approved" event' do
        save_company = Company.find(100)
        expect(Event).to have_received(:create).with(:COMP_APPROVED, save_company)
      end

      it 'send email invite to company person' do
        expect(company.company_people[0].user)
          .to have_received(:send_confirmation_instructions)
      end

      it 'completes pending_registration Task' do
        expect(Task.all.length).to be 1
        expect(Task.all.first.status)
          .to eq TaskManager::TaskManager::STATUS[:DONE]
      end
    end
  end
end
