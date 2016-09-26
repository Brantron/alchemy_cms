require 'spec_helper'

RSpec.feature 'Picture caching feature', :js do
  let!(:picture) { create(:alchemy_picture, name: 'Katzen sind süß') }

  let!(:essence) { create(:alchemy_essence_picture, picture: picture) }

  let!(:content) do
    create :alchemy_content,
      name: 'image',
      essence_type: 'Alchemy::EssencePicture',
      essence: essence
  end

  let!(:element) { create(:alchemy_element, name: 'header') }
  let!(:public_page) { create(:alchemy_page, :public) }

  let(:picture_cache_folder) do
    Rails.root.join('public', Alchemy::MountPoint.get, 'pictures')
  end

  before do
    FileUtils.rm_rf(Rails.root.join('tmp', 'cache'))
    element.contents << content
    public_page.elements << element
  end

  subject(:visit_page) { visit "/#{public_page.urlname}" }

  context "when caching is enabled" do
    before do
      Rails.application.config.action_controller.perform_caching = true
    end

    it 'stores pictures with id and url-unenscaped name' do
      visit_page
      expect(
        Dir.glob(
          File.join(
            picture_cache_folder,
            picture.id.to_s,
            '*',
            "#{picture.name}.#{picture.default_render_format}"
          )
        )
      ).to be_present
    end

    after do
      Rails.application.config.action_controller.perform_caching = false
      FileUtils.rm_rf(Rails.root.join('public', Alchemy::MountPoint.get, 'pictures'))
    end
  end

  context "when caching is disabled" do
    before do
      Rails.application.config.action_controller.perform_caching = false
    end

    it 'does not store pictures' do
      visit_page
      expect(File.exist?(picture_cache_folder)).to be(false)
    end
  end
end
