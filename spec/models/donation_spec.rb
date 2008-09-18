require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do

  assert_model_belongs_to :party
  assert_model_belongs_to :organisation

end
