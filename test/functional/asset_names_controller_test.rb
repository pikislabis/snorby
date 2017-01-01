require 'test_helper'

class AssetNamesControllerTest < ActionController::TestCase
  context 'admin user' do
    setup do
      @admin = users(:admin)
      sign_in @admin
    end

    should 'get assets' do
      get :index
      assert_response :success
    end

    should 'get new bulk upload form' do
      get :new_bulk_upload
      assert_response :success
    end

    should 'fail if upload wrong csv' do
      wrong_csv = fixture_file_upload('files/wrong_assets.csv', 'text/csv')
      post :bulk_upload, csv: wrong_csv
      assert_response 302
      assert_equal flash[:notice], 'There was an error uploading the file'
    end

    should 'upload csv' do
      csv = fixture_file_upload('files/assets.csv', 'text/csv')
      post :bulk_upload, csv: csv
      assert_response 302
      assert_equal flash[:notice], 'File Successfully Uploaded'
    end

    should 'add an asset' do
      assert_difference 'AssetName.count', 1 do
        post :add, ip_address: '109.207.194.248', name: 'asset_test',
                   global: 'true', format: :json
      end
    end

    should 'update a global asset' do
      assert_difference 'AgentAssetName.count', -2 do
        post :add, id: asset_names(:one).id,
                   ip_address: asset_names(:one).ip_address,
                   name: 'sensorIPS_changed', global: 'true',
                   format: :json
      end
    end

    should 'update a non global asset' do
      assert_difference 'AgentAssetName.count', 1 do
        post :add, id: asset_names(:two).id,
                   ip_address: asset_names(:two).ip_address,
                   name: asset_names(:two).name,
                   global: 'false', sensors: [sensors(:one).id],
                   format: :json
      end
    end

    should 'remove an asset' do
      assert_difference 'AssetName.count', -1 do
        delete :remove, id: asset_names(:one).id
      end
    end
  end

  context 'non admin user' do
    setup do
      @user = users(:user)
      sign_in @user
    end

    should 'not get assets' do
      get :index
      assert_response 302
    end
  end
end
