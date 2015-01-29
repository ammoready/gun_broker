require 'spec_helper'

describe GunBroker::Item do

  let(:attrs) { {"itemID"=>465370483, "bids"=>0, "eligibleForImmediateCheckout"=>false, "endingDate"=>"2015-02-25T15:37:19Z", "isFeaturedItem"=>false, "isFixedPrice"=>true, "isHighlighted"=>false, "isShowCaseItem"=>false, "isTitleBoldface"=>false, "hasBuyNow"=>false, "hasColor"=>false, "hasQuickLook"=>false, "hasPictures"=>true, "hasReserve"=>false, "hasReserveBeenMet"=>false, "highBidderID"=>0, "quantity"=>3, "price"=>49.99, "serialNumber"=>"", "sku"=>"", "subTitle"=>"", "thumbnailURL"=>"http://pics.gunbroker.com/GB/465370000/465370483/thumb.jpg", "timeLeft"=>"P26DT18H30M48S", "title"=>"Magpul STR Carbine Stock Mil Spec Black", "titleColor"=>"#000000", "links"=>[{"rel"=>"self", "href"=>"https://api.gunbroker.com/v1/items/465370483", "verb"=>"GET", "title"=>"465370483"}]} }

  it 'should have an #id' do
    item = GunBroker::Item.new(attrs)
    expect(item.id).to eq(attrs['itemID'])
  end

end
