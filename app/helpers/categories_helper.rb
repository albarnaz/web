module CategoriesHelper
  def category_button(current)
    content = safe_join([category_button_text(current), ' ',
                         content_tag(:span, '', class: 'caret')])
    content_tag(:button, content, class: 'btn primary dropdown-toggle',
                                  id: 'category_dropdown', type: 'button',
                                  data: { toggle: 'dropdown' },
                                  aria: { haspopup: 'true', expanded: 'true' })
  end

  def category_collection(categories, index_path)
    categories = categories.unshift(content_tag(:li, link_to(t('category.index'), index_path)))
    content_tag(:ul, safe_join(categories), class: 'dropdown-menu',
                                            aria: { labelled_by: 'category_dropdown' })
  end

  def category_button_text(category)
    if category.present?
      category
    else
      I18n.t('category.title')
    end
  end

  def category_link(category, path)
    content_tag(:li, link_to(category, path))
  end
end
