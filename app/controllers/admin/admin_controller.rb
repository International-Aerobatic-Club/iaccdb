class Admin::AdminController < ApplicationController

  before_action :get_admin_menu_items

  private

  def get_admin_menu_items

    @menu_items = [
      { label: 'Contests', path: admin_contests_path },
      { label: 'Data Posts', path: admin_data_posts_path },
      { label: 'Failures', path: admin_failures_path },
      { label: 'Free Ks', path: admin_free_program_ks_path },
      { label: 'Job Queue', path: admin_queues_path },
      { label: 'Makes & Models', path: admin_make_models_path },
      { label: 'Members', path: admin_members_path },
      { label: 'Recompute Awards', path: admin_recompute_path },
    ]

  end

end
