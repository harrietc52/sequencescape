module StudiesHelper
  def status_link_title
    if @study.inactive? || @study.pending?
      'Open'
    else
      'Close'
    end
  end

  def display_owners(study)
    owners_for_display(study.owners)
  end

  private

  def owners_for_display(owners)
    owners.empty? ? 'Not available' : owners.map(&:name).join(', ')
  end

  public

  def display_file_icon(document)
    return icon('fas', 'exclamation-circle', class: 'text-danger') unless document

    case document.content_type
    when /pdf/
      icon('far', 'file-pdf', title: 'PDF')
    when /word/
      icon('far', 'file-word', title: 'Word')
    when /excel/
      icon('far', 'file-excel', title: 'Excel')
    else
      icon('far', 'file-alt')
    end
  end

  def label_asset_state(asset)
    asset.closed? ? 'closed' : 'open'
  end

  def study_link(study, options)
    link_text = content_tag(:strong, study.name) << ' ' <<
                content_tag(:span, study.state, class: "study-state badge badge-#{study.state}")
    link_to(link_text, study_path(study), options)
  end
end
