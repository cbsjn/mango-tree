class SyncingErrorsController < ApplicationController
	def index
		@errors = SyncingError.where(user_id: current_user, status: 'unresolved').paginate(page: params[:page], per_page: PAGINATION_COUNT).order("created_at desc")
	end

	def delete_errors
		SyncingError.where(user_id: current_user).destroy_all
		flash[:notice] = 'All Errors Deleted Successfully.'
		redirect_to syncing_errors_path
	end
end
