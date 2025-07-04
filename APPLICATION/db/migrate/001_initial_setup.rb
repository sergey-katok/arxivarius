class CreateTranslits < ActiveRecord::Migration
  def self.up
    execute "
    CREATE TABLE `directories` (
        `id` int(10) unsigned NOT NULL default '0',
        `name` varchar(255) NOT NULL default '',
        `parent_id` int(11) unsigned NOT NULL default '0',
        `level` int(11) unsigned NOT NULL default '0',
        `path` text NOT NULL,
        PRIMARY KEY  (`id`),
        KEY `parent` (`parent_id`),
        KEY `level` (`level`)
      );

    CREATE TABLE `fils` (
        `id` int(10) unsigned NOT NULL default '0',
        `name` varchar(255) NOT NULL default '',
        `directory_id` int(10) unsigned NOT NULL default '0',
        `path` varchar(100) NOT NULL default '',
        PRIMARY KEY  (`id`)
      );

    CREATE TABLE `mp3tags` (
        `id` int(10) unsigned NOT NULL auto_increment,
        `fil_id` int(10) unsigned NOT NULL default '0',
        `title` varchar(100) NOT NULL default '',
        `track` varchar(100) NOT NULL default '',
        `artist` varchar(100) NOT NULL default '',
        `album` varchar(100) NOT NULL default '',
        `comment` varchar(100) NOT NULL default '',
        `year` varchar(100) NOT NULL default '',
        `genre` varchar(100) NOT NULL default '',
        PRIMARY KEY  (`id`)
      );

    CREATE TABLE `translits` (
        `id` int(10) unsigned NOT NULL auto_increment,
        `original` varchar(100) NOT NULL default '',
        `translated` varchar(100) NOT NULL default '',
        PRIMARY KEY  (`id`),
        UNIQUE KEY `word` (`original`)
     ); 
    "
  end

  def self.down
    drop_table :translits
  end
end
