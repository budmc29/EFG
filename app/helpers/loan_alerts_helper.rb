module LoanAlertsHelper
  def loan_alerts_priority(priority)
    return if priority.blank?
    secondary_class_name = case priority
    when "high"
      'label-important'
    when "medium"
      'label-warning'
    when "low"
      'label-success'
    end

    if params[:priority]
      content_tag(:div, "#{params[:priority].titleize} Priority", class: "label #{secondary_class_name}")
    end
  end

  def other_alert_links(groups, current_priority)
    links = []

    selected_button_class = "btn btn-info #{current_priority}"
    unselected_button_class = "btn #{current_priority}"

    links << link_to("All Loan Alerts", url_for, class: current_priority.blank? ? selected_button_class : unselected_button_class)

    groups.each do |g|
      button_class = g.priority == current_priority ? selected_button_class : unselected_button_class
      links << link_to("#{g.name} Priority Alerts", url_for(priority: g.priority), class: button_class)
    end

    links << link_to('Export CSV', url_for(format: :csv, priority: current_priority), class: 'btn btn-primary pull-right')

    content_tag :div, class: 'form-actions' do
      links.join.html_safe
    end
  end

end
