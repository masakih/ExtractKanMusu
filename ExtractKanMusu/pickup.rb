


require 'rubygems'
require 'sqlite3'
require 'uri'
 
db = SQLite3::Database.new("Cache.db")

cursor = db.execute("select request_key, receiver_data from cfurl_cache_response INNER JOIN cfurl_cache_receiver_data ON  cfurl_cache_response.entry_ID = cfurl_cache_receiver_data.entry_ID where cfurl_cache_response.request_key LIKE '%resources/swf/ships/%';")


currentPath = File.expand_path('fsCachedData/')
tempDir = File.expand_path('___temp_chu-chu-_ship___')

cursor.each do |row|
        aURI = URI.split(row[0])
#       p aURI
        fullpath = aURI[5]
        dir, file = File::split(fullpath)
        param = aURI[7]
        unless param
                filename = file
        else
                filename = param + "_" + file
        end
        
        original = File.expand_path(row[1], currentPath)
        copy = File.expand_path(filename, tempDir)
        
        command = 'cp ' + '"' + original + '"' + " " + '"' + copy + '"'
        system(command)
end
