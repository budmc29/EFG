class RealisationsReportPresenter
  include ActiveModel::Model
  include PresenterFormatterConcern

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  delegate :realisations, to: :report

  format :start_date, with: QuickDateFormatter
  format :end_date, with: QuickDateFormatter

  attr_reader :lenders, :report, :lender_ids

  validates_presence_of :end_date
  validates_presence_of :lender_ids
  validates_presence_of :start_date
  validate :end_date_is_not_after_start_date

  def initialize(user, options={})
    @user = user
    super(options)
    @report = RealisationsReport.new(start_date, end_date, lender_ids)
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

  attr_reader :user

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
