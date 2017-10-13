require 'spec_helper'

describe GunBroker::Error do

  it { expect(GunBroker::Error::NotAuthorized).to respond_to(:new) }
  it { expect(GunBroker::Error::NotFound).to respond_to(:new) }
  it { expect(GunBroker::Error::RequestError).to respond_to(:new) }
  it { expect(GunBroker::Error::TimeoutError).to respond_to(:new) }

end
