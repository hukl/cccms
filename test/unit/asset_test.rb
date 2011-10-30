require 'test_helper'

class AssetTest < ActiveSupport::TestCase

  test "related assets get destroyed when assets get destroyed" do
    Asset.delete_all
    RelatedAsset.delete_all

    assert asset  = Asset.create
    assert node   = Node.root.children.create( :slug => "asset" )
    assert_equal [], node.draft.assets

    draft = node.draft
    draft.assets << asset
    assert_equal 1, draft.assets.length

    asset.destroy
    draft.reload
    assert_equal 0, draft.assets.length
    assert_equal 0, RelatedAsset.count
  end

end
