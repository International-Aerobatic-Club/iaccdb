class PagesController < ApplicationController
  def page_view
    requested_page = params[:title]
    available_pages_pattern = File.join(Rails.root, 'app', 'views', 'pages', '*')
    available_page_names = Dir.glob(available_pages_pattern).collect do |fn|
      page_name = File.basename(fn)
      dot_pos = page_name.index('.')
      if dot_pos
        page_name = page_name[0,dot_pos]
      end
      page_name
    end
    if available_page_names.include? requested_page
      render requested_page
    else
      head :not_found
    end
  end

  def robots
  end
end
