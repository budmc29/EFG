module ApplicationHelper
  def breadcrumbs(*items)
    items.unshift(link_to('Home', root_path))
    divider = content_tag(:span, '/', class: 'divider')
    lis = []

    items.each_with_index do |item, index|
      lis << content_tag(:li, item + divider)
    end

    content_tag :ul, lis.join('').html_safe, class: 'breadcrumb'
  end

  def breadcrumbs_for_loan(loan, *extras)
    breadcrumbs(*[
      link_to('Loan Portfolio', loan_states_path),
      link_to("Loan #{loan.reference}", loan_path(loan))
    ])
  end

  def friendly_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def current_user_access_restricted?
    current_user.disabled? || current_user.locked?
  end

  def google_analytics
    return unless Rails.env.production?

    account, domain = Plek.current.environment == "preview" ?
      ['UA-34504094-2', 'preview.alphagov.co.uk'] :
      ['UA-34504094-1', 'production.alphagov.co.uk']

    user_type   = current_user ? current_user.type : nil
    lender_name = %w(LenderAdmin LenderUser).include?(user_type) ? current_lender.name : nil

    render "shared/google_analytics", account: account, domain: domain, user_type: user_type, lender_name: lender_name
  end

  def simple_form_row(label, control)
    content_tag :div, class: 'control-group' do
      content_tag(:div, label, class: 'control-label') +
        content_tag(:div, control, class: 'controls')
    end
  end
end
