class RealisationsReportPresenter
  include ActiveModel::Model
  include PresenterFormatterConcern

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  delegate :realisations, to: :report

  format :start_date, with: QuickDateFormatter
  format :end_date, with: QuickDateFormatter

  attr_reader :report, :lender_ids

  validates_presence_of :end_date
  validates_presence_of :lender_ids
  validates_presence_of :start_date
  validate :end_date_is_not_after_start_date

  def initialize(user, options={})
    @user = user

    if !must_select_lenders?
      options['lender_ids'] = [ALL_LENDERS_OPTION.id]
    end

    super(options)
    @report = RealisationsReport.new(start_date, end_date, lender_ids)
  end

  def allowed_lenders
    user_lenders.order_by_name.unshift(ALL_LENDERS_OPTION)
  end

  def lender_ids=(ids)
    @lender_ids = if ids.include?(ALL_LENDERS_OPTION.id)
      user_lenders.pluck(:id)
    else
      user_lenders.where(id: ids).pluck(:id)
    end
  end

  def lender_names
    user_lenders.where(id: lender_ids).order_by_name.pluck(:name)
  end

  def must_select_lenders?
    user_lenders.count > 1
  end

  private

  attr_reader :user

  def end_date_is_not_after_start_date
    if start_date && end_date && end_date < start_date
      errors.add(:start_date, :must_be_before_end_date)
      errors.add(:end_date, :must_be_after_start_date)
    end
  end

  def user_lenders
    @user_lenders ||= user.lenders
  end
end
