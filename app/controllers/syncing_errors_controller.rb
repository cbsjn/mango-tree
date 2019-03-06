class SyncingErrorsController < ApplicationController
	def index
		@errors = SyncingError.where(status: :resolved).paginate(page: params[:page], per_page: PAGINATION_COUNT).order("created_at desc")
	end
end
