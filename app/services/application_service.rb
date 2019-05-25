class ApplicationService
  attr_reader :status
  attr_reader :error

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
    error = nil
  end

  def failed(e)
    @status = :failed
    @error = e
  end
end
