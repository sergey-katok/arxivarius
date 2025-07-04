class Directory < ActiveRecord::Base
    has_many :fils

    def subs
        return Directory.find(:all, :conditions => ["parent_id = ?", self.id], :order => 'name ASC')
    end

    #all levels deep sub dirs
    def subs_all
        subs_all = []
        return subs_all if self.subs.empty?
        self.subs.each do |dir|
            subs_all << dir
            dir.subs_all.each do |subdir|
                subs_all << subdir
            end
        end
        return subs_all
    end


    def navigation
        parts = self.path.split('\\')
        parts_w_links = []
        part_path = ''
        parts.each do |part|
            part_path += part + '\\'
            part_path1 = part_path.sub(/\\$/,'')
            part_dir = Directory.find_dir_by_path(part_path1)
            if part_dir
                parts_w_links << "<nobr><a href=/browse/show/" + part_dir.id.to_s + ">" + part_dir.title + "</a></nobr>"
            end
        end
        return parts_w_links.join(" <img src=/images/arrow_small.gif> ")
    end

    def title
        return self.new_name if !self.new_name.empty?
        return self.author_album if !self.author_album.nil? && !self.author_album.empty? && self.author_album !~ /track/i && self.author_album !~ /\"\d.*\d\"$/i
        return Translit.translate(self.name) if self.is_russian?
        return self.name
    end

    def author_album
        return nil if !(self.fils.size>0)
        if self.numlist?

            return
                (!self.fils[0].mp3tag.artist.empty? ? self.fils[0].mp3tag.artist : '') +
                (!self.fils[0].mp3tag.album.empty? ? ' - ' + self.fils[0].mp3tag.album : '') +
                (!self.fils[0].mp3tag.title.empty? ? ' "'  + self.fils[0].mp3tag.title + '"' : '')

        end

    end

    def parent
     parent_dir =  Directory.find(:first, :conditions => ["id = ?", self.parent_id])
     return parent_dir || self
    end

    def numlist?
        self.fils.each do |fil|
            return false if fil.name_wo_ext !~ /\d$/
        end
        return true
    end

    def self.find_dir_by_path(path)
        return Directory.find(:first, :conditions => ["path = ?", path])
    end

    def is_russian?
        ( path =~ /russian/i  || path =~ /рус/i ? true : false || path =~ /јудио ниги/i)
    end

    def is_online
        return self.parent.is_online if self.id != 0 && self.parent != self && !self.parent.is_online
        return self.online
    end

   def icon
        icon = ''
        if self.is_online
            icon += "<img src='/images/arrow_right.gif' title='#{self.path}'>"
        else
            icon += "<img src='/images/spacer.gif' width=15 height=15>"
        end
        if self.archive_num > 0
            icon += "<img src='/images/archive.gif' title='јрхив ##{self.archive_num}'>"
        else
            icon += "<img src='/images/spacer.gif' width=20 height=17>"
        end
        return icon
   end




    ############ архивирование | offline | в лучшее
    def archive_num
        return 0 if self.id == 0
        return self.archive
    end

    def archivize(archive_id)
        if !self.is_online
            return
        end
        self.update_attribute(:archive, archive_id)
    end

    def offline
        if self.best || !self.archive_num || !self.is_online
            return
        end
        self.update_attribute(:online, 0)
        #delete directory from disk
        Dir.delete(self.path)
    end

    def move_variants
        vars = Directory.find(:all, :conditions => ["name = ? AND id != ?", self.name, self.id], :limit => 5)
        vars.delete_if {|dr| dr.name =~ /^\d+\_\d+$/ || dr.name =~ /^\d+$/ || dr.name == 'made'}
        return vars
    end

    def in_best
        self.update_attribute(:best, 1)
    end



end
