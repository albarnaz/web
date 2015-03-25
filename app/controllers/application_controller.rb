# encoding:UTF-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :configure_permitted_devise_parameters, if: :devise_controller?
  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |ex|
    flash[:error] = ex.message
    render :text => '', :layout => true, :status => :forbidden
  end

  rescue_from ActiveRecord::RecordInvalid do |ex|
    flash[:error] = 
      "Fel i formulär:  #{ex.record.errors.full_messages.join '; '}"
    render referring_action, :status => :unprocessable_entity
  end

  protected
  def configure_permitted_devise_parameters
    devise_parameter_sanitizer.for(:sign_in) {|u| u.permit(:username, :password, :remember_me)}
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:username, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:password, :password_confirmation, :current_password) }
  end

  def self.permission
    self.name.gsub('Controller','').singularize.split('::').last.constantize.name rescue nil
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  #load the permissions for the current user so that UI can be manipulated
  def load_permissions(*args)
    @current_permissions = current_user.profile.posts.each do |post|
      post.permissions.collect{|i| [i.subject_class, i.action]}
    end
  end

  # Enables authentication and 
  def self.load_permissions_and_authorize_resource(*args)
    load_and_authorize_resource(*args)
    before_filter(:load_permissions, *args)
  end

  def self.skip_authorization(*args)
    skip_authorization_check(*args)
    skip_before_filter(:load_permissions, *args)
  end

  def set_locale
    locale = 'sv'
    langs  = %w{ sv en }

    if params[:locale]
      lang = params[:locale]
      if langs.include? lang
        locale           = lang
        cookies[:locale] = lang
      end
    else
      if cookies[:locale]
        lang   = cookies[:locale]
        locale = lang if langs.include? lang
      end
    end

    I18n.locale = locale
    redirect_to(:back) if params[:locale]
  end

  def referring_action
    Rails.application.routes.recognize_path(request.referer)[:action]
  end
end
