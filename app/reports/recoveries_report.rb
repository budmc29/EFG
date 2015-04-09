require 'csv'

class RecoveriesReport
  include ActiveModel::Model
  include PresenterFormatterConcern

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  format :start_date, with: QuickDateFormatter
  format :end_date, with: QuickDateFormatter

  attr_reader :lender_ids

  validates_presence_of :start_date, :end_date, :lender_ids
  validate :end_date_is_not_after_start_date

  def initialize(current_user, options={})
    @current_user = current_user
    super(options)
  end

  def allowed_lenders
    return lenders_whitelist.order_by_name.unshift(ALL_LENDERS_OPTION) if lenders_whitelist.count > 1
    lenders_whitelist
  end

  def any_recoveries?
    recoveries.size > 0
  end

  def lender_ids=(ids = [])
    @lenders = if ids.include? 'ALL'
      lenders_whitelist
    else
      Lender.where(id: ids).select { |lender| allowed_lenders.include? lender }
    end
    @lender_ids = @lenders.map(&:id)
  end

  def lender_names
    @lenders.map(&:name)
  end

  def recoveries
    @recoveries ||= Recovery
      .joins(:loan => :lender)
      .where(recovered_on: start_date..end_date,
            'loans.lender_id' => lender_ids)
      .select('recoveries.*, loans.reference AS loan_reference, lenders.name AS lender_name, realise_flag AS realised')
  end

  def size
    @size ||= recoveries.size
  end

private

  attr_reader :current_user

  def end_date_is_not_after_start_date
    if start_date.present? &&
        end_date.present? &&
        end_date < start_date
      errors.add(:start_date, :must_be_before_end_date)
      errors.add(:end_date, :must_be_after_start_date)
    end
  end

  def lenders_whitelist
    current_user.lenders
  end

end
