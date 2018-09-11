require 'rails_helper'

feature 'View study properties' do
  let(:user) { create :admin }
  let(:prelim_id) { 'A1234' }
  let(:study) { create(:study, study_metadata: create(:study_metadata, { prelim_id: prelim_id })) }

  scenario 'view open study properties', js: true do
    login_user(user)
    visit study_path(study)
    click_link 'Study details'
    expect(page).to have_content('Alignments in BAM: true')
    expect(page).not_to have_content('HMDMC approval number: ')
    expect(page).to have_content("Prelim ID: #{prelim_id}")
  end

  scenario 'view properties of a study that requires ethical approval' do
    study.study_metadata = create :study_metadata_for_study_list_pending_ethical_approval
    study.study_metadata.hmdmc_approval_number = '12345'
    study.save

    login_user(user)
    visit study_path(study)
    click_link 'Study details'
    expect(page).to have_content('HMDMC approval number: 12345')
  end
end
