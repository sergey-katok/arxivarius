class Fil < ActiveRecord::Base
     belongs_to :directory
     has_one :mp3tag

     #url to access local files
     BASE_URL = 'http://localhost'

     def title

        return self.new_name if !self.new_name.empty?

        return Translit.translate(name_wo_ext) + extension if self.directory.is_russian? && self.name !~ /track/i

        return name
     end

     def name_wo_ext
        name_rev = name.reverse
        name_rev.sub!(/.*?\./, '')
        return name_rev.reverse
     end

     def extension
        return name.gsub(/.*\./,'.')
     end

     def mp3summary
        return '' if self.mp3tag.nil?
        (!self.mp3tag.title.empty?  ? self.mp3tag.title : '') +
        (!self.mp3tag.artist.empty? ? '<br>'+self.mp3tag.artist : '') +
        (!self.mp3tag.album.empty?  ? '<br>'+self.mp3tag.album : '') +
        (!self.mp3tag.year.empty?   ? '<br>'+self.mp3tag.year : '') +
        (!self.mp3tag.comment.empty?   ? '<br>'+self.mp3tag.comment : '')
     end

     def url
        url_path = self.path
        url_path.sub!( /C:\\ћузыка/, BASE_URL+'/ћузыка')
        url_path.sub!( /D:\\јудио ниги/, BASE_URL+'/јудио ниги')
        url_path.gsub!(/\\/, '/')
        return url_path
     end

     def icon
        icon = ''
        if self.is_online
            icon += "<img src=/images/sound.gif title='#{self.path}'>"
        else
            icon += "<img src='/images/spacer.gif' width=15 height=15>"
        end
        if self.archive_num > 0
            icon += "<img src=/images/archive.gif title='јрхив ##{self.archive_num} -- #{self.name}'>"
        else
            icon += "<img src='/images/spacer.gif' width=20 height=17>"
        end
        return icon
     end

     def link
         return "<a href='#{self.url}'>#{self.title}</a>" if self.is_online
         return "<span class=offline>#{self.title}</span>"
     end

     def is_online
         return false if self.directory && !self.directory.is_online
         return self.online
     end

     ############ архивирование | offline | в лучшее
     def archive_num
         return self.archive
     end

     def archivize(archive_id)
         if !self.is_online
             return
         end
        self.update_attribute(:archive, archive_id)
     end

     def offline
        #don't allow to remove best or not archived
        if self.best || !(self.archive_num>0) || !self.is_online
            return
        end
        self.update_attribute(:online, 0)
        #delete file from disk
        File.delete(self.path)
     end

     def in_best
         self.update_attribute(:best, 1)
     end



end
