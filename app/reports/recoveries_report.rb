require 'csv'

class RecoveriesReport
  include ActiveModel::Model
  include PresenterFormatterConcern

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  format :recovered_on_start_date, with: QuickDateFormatter
  format :recovered_on_end_date, with: QuickDateFormatter

  attr_reader :lender_ids, :lenders

  validates_presence_of :recovered_on_start_date, :recovered_on_end_date, :lender_ids
  validate :recovered_on_end_date_is_not_after_recovered_on_start_date

  def initialize(current_user, options={})
    @current_user = current_user
    super(options)
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

  def recoveries
    @recoveries ||= Recovery
      .joins(:loan => :lender)
      .where(recovered_on: recovered_on_start_date..recovered_on_end_date,
            'loans.lender_id' => lender_ids)
      .select('recoveries.*, loans.reference AS loan_reference, lenders.name AS lender_name, realise_flag AS realised')
  end

private

  attr_reader :current_user

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
