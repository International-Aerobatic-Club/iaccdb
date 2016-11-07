class PagesController < ApplicationController
  def page_view
    requested_page = params[:title]
    available_pages_pattern = File.join(Rails.root, 'app', 'views', 'pages', '*')
    available_page_names = Dir.glob(available_pages_pattern).collect do |fn|
      name = File.basename(fn)
      dot_pos = name.index('.')
      if dot_pos
        name = name[0,dot_pos]
      end
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
