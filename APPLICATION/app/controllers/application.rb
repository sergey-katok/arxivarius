# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'fileutils'
include FileUtils

class ApplicationController < ActionController::Base

    #before_filter :authorise
    before_filter :set_db_charset
    after_filter :set_charset

    def set_charset
      content_type = @headers["Content-Type"] || 'text/html'
      if /^text\//.match(content_type)
        @headers["Content-Type"] = "#{content_type}; charset=windows-1251"
      end
    end

    def set_db_charset
        ActiveRecord::Base.connection.execute("SET NAMES 'cp1251'")
    end


    ####### Authentication
    def authorise
      # Log in using session data if it exists.
      if id = session["account_id"]
        @account = Account.find(id) and return true
      end

      # Otherwise log in from authentication data sent in request header.
      login, password = get_auth_data
      if login and password and @account = Account.authenticate(login, password)
        session["account_id"] = @account.id
        return true
      end

      # If no auth data, or wrong auth data, issue a challenge.
      response.headers["Status"] = "Unauthorized"
      response.headers["WWW-Authenticate"] = 'Basic realm="Realm"'
      render(:text => "Authentication required", :status => 401)
    end

    def deauthorise
      session.delete("account_id")
    end

    def get_auth_data
      auth_data = nil
      [
        'REDIRECT_REDIRECT_X_HTTP_AUTHORIZATION',
        'REDIRECT_X_HTTP_AUTHORIZATION',
        'X-HTTP_AUTHORIZATION',
        'HTTP_AUTHORIZATION'
      ].each do |key|
        if request.env.has_key?(key)
          auth_data = request.env[key].to_s.split
          break
        end
      end

      if auth_data && auth_data[0] == 'Basic'
        return Base64.decode64(auth_data[1]).split(':')[0..1]
      end
    end


end