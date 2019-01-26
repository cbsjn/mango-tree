class MappingsController < ApplicationController
  def index
    @message = params[:message]
    @message_class = params[:message_class]
    @mappings = Mapping.where(user_id: session[:user_id], name: params[:name])
  end

  def create
    mapping = Mapping.new(mapping_params)
    if mapping.save
      @message = 'Mapping Created Successfully'
    else
      @message_class = 'danger'
      @message = mapping.errors.full_messages.join(', ')
    end
    redirect_to mappings_path(:message => @message, name: params[:mapping][:name], message_class: @message_class)
  end

  def show
    mapping = Mapping.where(id: params[:id], user_id: session[:user_id]).first
    if mapping.present?
      mapping.destroy
      @message_class = 'success'
      @message = 'Mapping Deleted Successfully'
    else
      @message_class = 'danger'
      @message = 'Restricted Access'
    end
    redirect_to mappings_path(:message => @message, name: params[:name], message_class: @message_class)
  end

  def change_dropdown_values
    @mapping_name = params[:mapping_name]
    respond_to do |format|
      format.js
    end
  end

  private
  def mapping_params
    params.require(:mapping).permit!
  end
end
