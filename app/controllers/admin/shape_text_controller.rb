class Admin::ShapeTextController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:profile_editor])
  end
	cache_sweeper :unique_shape_name_sweeper, :only => [:create, :update, :destroy]

  # GET /shape_text
  # GET /shape_text.json
  def index
    @shape_text = UniqueShapeName.for_profiles

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shape_text }
    end
  end

  # GET /shape_text/1/edit
  def edit
    @shape_text = UniqueShapeName.for_profiles.readonly(false).find_by_id(params[:id])

    if @shape_text.present?
      if request.post?
        respond_to do |format|
          if @shape_text.update_attributes(params[:unique_shape_name])
				    msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.shape'))
				    send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
            format.html { redirect_to admin_shape_text_path, notice: msg }
            format.json { head :ok }
          else
            format.html { render action: "edit" }
            format.json { render json: @shape_text.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @shape_text }
        end
      end
    else
			# no page was found, send back to home
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_shape_text_path
    end
  end

end
