class ApplicationService
  attr_reader :status
  attr_reader :result

  # -- Please override following methods ---
  def initialize; end
  def execute!; end
  # ----------------------------------------

  def success?
    @status == :success
  end

  def failed?
    @status == :failed
  end

  private

  def success
    @status = :success
  end

  def failed(e)
    @status = :failed
    @result = e
  end
end
