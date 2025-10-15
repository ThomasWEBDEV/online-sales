module ApplicationHelper
  include ActionView::Helpers::TextHelper
  include Pagy::Frontend  # Pagination frontend

  def breadcrumbs(*links)
    content_tag :nav, class: "breadcrumbs" do
      content_tag :div, class: "container" do
        content_tag :ol, class: "breadcrumb" do
          content_tag(:li, link_to("Accueil", root_path), class: "breadcrumb-item") +
          links.map do |text, path|
            if path
              content_tag(:li, link_to(text, path), class: "breadcrumb-item")
            else
              content_tag(:li, text, class: "breadcrumb-item active")
            end
          end.join.html_safe
        end
      end
    end
  end

  def highlight_search_terms(text, query)
    if query.present?
      highlight(text, query, highlighter: '<mark class="search-highlight">\1</mark>')
    else
      text
    end
  end
end
