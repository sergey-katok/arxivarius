class BrowseController < ApplicationController

    def show
        @current_archive = self.current_archive
        @id = params[:id] || 0
        @dr = Directory.find(@id)
        @mode = session[:mode]
        @mode ||= 'maintain'
        @totals = '<br>Директории: ' + @dr.subs.size.to_s + '<br>Файлы: ' + @dr.fils.size.to_s;
    end


    def current_archive
        Archive.find(:first, :order => "id DESC")
    end

    def best
        @dirs = Directory.find(:all, :conditions => "best=1")
        @fils = Fil.find(:all, :conditions => "best=1")
    end

    def search
        @name = params[:name]
        @dirs = Directory.find(:all, :limit => 100, :conditions => ["name LIKE ?", '%'+@name+'%'])
        @fils = Fil.find(:all, :limit => 100, :conditions => ["name LIKE ?", '%'+@name+'%'])
    end


end
