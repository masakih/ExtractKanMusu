require 'sqlite3'

db = SQLite3::Database.new("Cache.db")

cursor = db.execute("SELECT request_key, receiver_data FROM cfurl_cache_response INNER JOIN cfurl_cache_receiver_data ON  cfurl_cache_response.entry_ID = cfurl_cache_receiver_data.entry_ID where cfurl_cache_response.request_key LIKE '%resources/ship/%' AND NOT cfurl_cache_response.request_key LIKE '%album_status%';")

print "[\n"
cursor.each do |row|
    print "\t{\n"
    
    print "\t\t\"url\": \""
    print row[0]
    print "\",\n"
    
    print "\t\t\"filename\": \""
    print row[1]
    print "\"\n"
    
    print "\t},\n"
end
print "]\n"
