#Oracle Apex Region Plugin - Timeline
Timeline is a region type plugin that allows you to draft very nice looking timelines with a single sql query.
It is based on JS Framework timeline.js (https://github.com/NUKnightLab/TimelineJS).

You can embed various sorts of media via URLs, for example:
- simple Images
- Videos
- Music
- Youtube
- Flickr 
- Twitter
- Google Maps
- and many more, read more on timeline.js homepage.

##Changelog
####1.0 - Initial Release

##Install
- Import plugin file "region_type_plugin_de_danielh_timeline.sql" from source directory into your application
- (Optional) Deploy the CSS/JS files from "server" directory on your webserver and change the "File Prefix" to webservers folder.

##Plugin Settings
The plugin settings are highly customizable and you can change:
- Headline of master page
- Description of master page
- Media URL of master page
- Choose between 17 fonts
- Choose between 60 languages, just enter the language code
- set the default width(pixel and percent) and height(only pixel)
- All the rest comes out of your sql query.

####Example SQL Query:
```language-sql
SELECT start_date (date),
       end_date (date),
       headline (varchar2),
       description (varchar2 - nullable),
       media_url (varchar2 - nullable)
  FROM timeline
```
##Demo Application
https://apex.oracle.com/pls/apex/f?p=57743:9

---

At the moment only whole days are supported. Support for hours is planned for future releases.
