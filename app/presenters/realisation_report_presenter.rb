class RealisationReportPresenter
  include ActiveModel::Model
  include PresenterFormatterConcern

  attr_reader :realised_on_start_date, :realised_on_end_date, :lender_ids, :lenders, :report, :current_user

  ALL_LENDERS_OPTION = OpenStruct.new(id: 'ALL', name: 'All').freeze

  delegate :realisations, :to_csv, to: :report

  def initialize(current_user, options={})
    @current_user = current_user
    lender_ids = options.fetch(:lender_ids, [])
    @realised_on_start_date = options.fetch(:realised_on_start_date, nil)
    @realised_on_end_date = options.fetch(:realised_on_end_date, nil)
    @lenders = Lender.find(lender_ids).select{ |l| allowed_lenders.include? l }
    @lender_ids = @lenders.map(&:id)
    @report = RealisationReport.new(@realised_on_start_date, @realised_on_end_date, @lender_ids)
  end

  def allowed_lenders
    lenders_whitelist = current_user.lenders
    return lenders_whitelist.order_by_name.unshift(ALL_LENDERS_OPTION) if lenders_whitelist.count > 1
    lenders_whitelist
  end

  def record_count
    realisations.count
  end

end
