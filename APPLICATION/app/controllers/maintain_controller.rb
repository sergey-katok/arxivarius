class MaintainController < ApplicationController

	require 'fileutils'

    def index
        mode = session[:mode]
        mode ||= 'regular'
        if mode == 'maintain'
            @mode_text = 'Служебный режим'
            @alt_mode_text = 'обычный режим'
            @alt_mode = 'regular'
        else
            @mode_text = 'Обычный режим'
            @alt_mode_text = 'служебный режим'
            @alt_mode = 'maintain'
        end
    end

    def new_archive
    end

    def create_archive
        archive = Archive.create( :directory_id => params[:directory_id], :comments => params[:comments] )
        render_text "Новый архив создан: #" + archive.id.to_s
    end

    def not_archived

        @limit = 1000

        drs = Directory.find(:all, :conditions => "archive = 0 AND path NOT LIKE '%Karaoke%' AND ( level = 3 OR level = 4 ) ", :order => "parent_id");
        @drs = []
        i = 0
        drs.each do |dr|
            next if dr.path.empty?
            next if !dr.is_online
            next if @drs.include?(dr.parent)

            next if dr.parent.archive != 0
            @drs << dr
            i += 1
            break if i > 1000
        end


        fils = Fil.find(:all, :conditions => "archive = 0 AND path NOT LIKE '%Karaoke%' AND path NOT LIKE '%katok%'", :limit => @limit);
        @fils = []
        i = 0
        fils.each do |fl|
            next if fl.path.empty?
            next if !fl.is_online
            next if @drs.include?(fl.directory)

            next if fl.directory.archive != 0
            @fils << fl
            i += 1
            break if i > @limit
        end
    end


    def find_deleted
        drs = Directory.find(:all, :conditions => "online=1");
        @drs = []
        i = 0
        drs.each do |dr|
            next if dr.path.empty?
            next if !dr.is_online
            next if File.exist?(dr.path)
            next if @drs.include?(dr.parent)
            @drs << dr
            i += 1
            break if i > 100
        end

        fils = Fil.find(:all, :conditions => "online=1");
        @fls = []
        j = 0
        fils.each do |fil|
            next if fil.path.empty?
            next if !fil.is_online
            next if File.exist?(fil.path)
            next if @drs.include?(fil.directory)
            next if fil.path =~ /french|lacrimosa/i
            @fls << fil
            j += 1
            break if j > 100
        end
    end

    def process_deleted
        @type = params[:type]

        #process dirs
        if @type == 'dir'
            dir_ids = params[:delete]
            @drs = []
            @sbs = {}
            dir_ids.each do |dir_id|
                @drs << Directory.find(dir_id)
            end

            #find subdirs
            @drs.each do |dir|
                @sbs[dir] = ''

                #find files
                dir.fils.each do |fil|
                    @sbs[dir] += '<li>' + fil.path + '</li>'
                    Fil.delete(fil.id)
                end

                dir.subs_all.each do |subdir|
                    @sbs[dir] += '<li>' + subdir.path + '</li>'
                    #find files
                    subdir.fils.each do |fil|
                        @sbs[dir] += '<li>' + fil.path + '</li>'
                        Fil.delete(fil.id)
                    end
                    Directory.delete(subdir.id)
                end

                Directory.delete(dir.id)

            end
        end

        #process files
        if @type == 'fil'
            fil_ids = params[:delete]
            @fls = []
            fil_ids.each do |fil_id|
                @fls << Fil.find(fil_id)
                Fil.delete(fil_id)
            end
        end


    end

    def switch_mode
        mode = session[:mode]
        if mode == 'maintain'
            session[:mode] = 'regular'
        else
            session[:mode] = 'maintain'
        end
        render_text "<script>window.opener.location.reload();window.close();</script>"
    end

    def find_miss_par
        #dirs
        @drs = Directory.find_by_sql("
            SELECT d1.*
            FROM directories d1
            LEFT JOIN directories d2
            ON d2.id = d1.parent_id
            WHERE d2.id IS NULL
            LIMIT 100 ")

        @drs.sort! {|x,y| x.is_online.to_s <=> y.is_online.to_s}

        #fils
        @fls = Fil.find_by_sql("
            SELECT f.*
            FROM fils f
            LEFT JOIN directories d2
            ON d2.id = f.directory_id
            WHERE d2.id IS NULL
            LIMIT 100 ")

        @fls.sort! {|x,y| x.is_online.to_s <=> y.is_online.to_s}
    end

    def archivize
            @process = params[:process] #archive | off-line | best
            @archive_id = params[:archive_id]

            #### dirs
            dir_ids = params[:dirs]
            @drs = []
            @sbs = {}

            #find subdirs
            if dir_ids

                dir_ids.each do |dir_id|
                    @drs << Directory.find(dir_id)
                end

                @drs.each do |dir|
                    @sbs[dir] = ''

                    #find files
                    dir.fils.each do |fil|
                        @sbs[dir] += '<li>' + fil.path + '</li>'
                        if @process == 'Off-line'
                            fil.offline
                        elsif @process == 'В лучшее'

                        else
                            fil.archivize(@archive_id)
                        end
                    end

                    dir.subs_all.each do |subdir|
                        @sbs[dir] += '<li>' + subdir.path + '</li>'
                        #find files
                        subdir.fils.each do |fil|
                            @sbs[dir] += '<li>' + fil.path + '</li>'
                            if @process == 'Off-line'
                                fil.offline
                            elsif @process == 'В лучшее'

                            else
                                fil.archivize(@archive_id)
                            end
                        end
                        if @process == 'Off-line'
                            subdir.offline
                        elsif @process == 'В лучшее'

                        else
                            subdir.archivize(@archive_id)
                        end
                    end

                    if @process == 'Off-line'
                        dir.offline
                    elsif @process == 'В лучшее'
                        dir.in_best
                    else
                        dir.archivize(@archive_id)
                    end
                end
            end

            ### fils
            fil_ids = params[:fils]
            @fls = []

            if fil_ids
                fil_ids.each do |fil_id|
                    @fls << Fil.find(fil_id)
                end

                @fls.each do |fil|
                    if @process == 'Off-line'
                        fil.offline
                    elsif @process == 'В лучшее'
                        fil.in_best
                    else
                        fil.archivize(@archive_id)
                    end
                end
            end

    end

    def rename
        @id = params[:id]
        if params[:is_dir] == '1'
            @dir = Directory.find(@id)
            @obj = @dir
            @old_name = @dir.name
            @is_dir = true
        else
            @fil = Fil.find(@id)
            @obj = @fil
            @old_name = @fil.name
            @is_dir = false
        end
    end

    def rename_process
        @id = params[:id]
        @new_name = params[:new_name]
        if params[:is_dir] == 'true'
            @dir = Directory.find(@id)
            @dir.update_attribute(:new_name, @new_name)
            div_name = 'dir_'+@id.to_s
        else
            @fil = Fil.find(@id)
            @fil.update_attribute(:new_name, @new_name)
            div_name = 'fil_'+@id.to_s
        end
        render_text "
            <script>
                window.opener.document.getElementById('#{div_name}').innerHTML = \"#{@new_name}\";
                window.close();
            </script>"
    end

    def move_select
        @submit = params[:submit]
        @id = params[:id]
        @prev_id = params[:prev_id]
        @dir_ids = ( !params[:dir_ids].nil? ? params[:dir_ids] : params[:dirs].to_s );
        @fil_ids = ( !params[:fil_ids].nil? ? params[:fil_ids] : params[:fils].to_s );
        if @id == '-1'
            prev_dir = Directory.find(@prev_id)
            parent_dir = prev_dir.parent
            @id = parent_dir.id
        end
        @cur_dir = Directory.find(@id)
        @subs = @cur_dir.subs

		@msg = ''
        if @submit == 'Переместить!'
            @new_dir = Directory.find(@id)
            #dirs
            @dir_ids = @dir_ids.sub(/^,/,'')
            dir_ids = @dir_ids.split(/,/)
            if dir_ids.size>0
                dir_ids.each do |dir_id|
                    dir = Directory.find(dir_id)
                    if File.exist?(dir.path)
                        next
                    end
                    dir.update_attributes(:parent_id => @id, :moved_from_id => @prev_id)
                end
            end
            #files
            @fil_ids = @fil_ids.sub(/^,/,'')
            fil_ids = @fil_ids.split(/,/)
            if fil_ids.size>0
                fil_ids.each do |fil_id|
                    fil = Fil.find(fil_id)
                    if File.exist?(fil.path)
                        @msg = '<br>Требуется перемещение файла:' + fil.path
						#mv(fil.path, "C:")
                    end
                    fil.update_attributes(:directory_id => @id, :moved_from_id => @prev_id)
                end
                render_text 'Перемещение завершено<br><br><a href=javascript:window.close()>Закрыть</a>' + @msg
            end
            render_text '<br>Перемещение завершено<br><br><a href=javascript:window.close()>Закрыть</a>' + @msg
            return
        end
    end


end
