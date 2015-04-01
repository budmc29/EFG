class RecoveriesReportPresenter
  include ActiveModel::Model
  include PresenterFormatterConcern

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  delegate :recoveries, to: :report

  format :recovered_on_start_date, with: QuickDateFormatter
  format :recovered_on_end_date, with: QuickDateFormatter

  attr_reader :lenders, :report, :current_user, :lender_ids

  validates_presence_of :recovered_on_start_date, :recovered_on_end_date, :lender_ids
  validate :recovered_on_end_date_is_not_after_recovered_on_start_date

  def initialize(current_user, options={})
    @current_user = current_user
    super(options)
    @report = RecoveriesReport.new(@recovered_on_start_date, @recovered_on_end_date, @lender_ids)
  end

  def allowed_lenders
    return lenders_whitelist.order_by_name.unshift(ALL_LENDERS_OPTION) if lenders_whitelist.count > 1
    lenders_whitelist
  end

  def lender_ids=(ids = [])
    @lenders = if ids.include? 'ALL'
      lenders_whitelist
    else
      Lender.where(id: ids).select { |lender| allowed_lenders.include? lender }
    end
    @lender_ids = @lenders.map(&:id)
  end

  private

  def lenders_whitelist
    current_user.lenders
  end

  def recovered_on_end_date_is_not_after_recovered_on_start_date
    if recovered_on_start_date.present? &&
        recovered_on_end_date.present? &&
        recovered_on_end_date < recovered_on_start_date
      errors.add(:recovered_on_start_date, :must_be_before_end_date)
      errors.add(:recovered_on_end_date, :must_be_after_start_date)
    end
  end

end
