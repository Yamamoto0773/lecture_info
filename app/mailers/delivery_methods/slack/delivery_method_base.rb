class Slack::DeliveryMethodBase
  attr_accessor :settings

  def initialize(value)
    self.settings = value
  end

  def deliver!(message)
    # please override this method
  end
end
