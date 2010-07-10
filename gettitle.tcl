######################### --- ABURL Stuffs --- ###############################
# 1.- When an user says a URL in the channel, the bot says the Title of the URL
# 2.- Saying the command .surl <url>, the bot says the bit.ly shorted url
#
#             Angel Gonzalez <me@angelbroz.com>

package require http
set urlpattern {(http|https)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]}

#your api here
set bitlyapi {R_7a0d1c3d308b4c789f1549c634319272d} 
#your but.ly user here
set bitlylogin {angelbroz} 

set bitlyurl {http://api.bit.ly/v3/shorten?login=}
set bitlyurl [concat $bitlyurl $bitlylogin "&apikey=" $bitlyapi "&longUrl="]

bind pubm - * checkurl

#Get the Url html and parses the Title in all html text
proc gettitle {urls} {
        set token [http::geturl $urls]
        set data  [http::data $token]
        set data [string map {\n ""} $data]
        set data [string map {"  " ""} $data]
        
        if {[regexp -nocase -- {>([^<>]+)</title>} $data title]} {
                http::cleanup $token
                set title [string range $title 1 end]
                set title [string map -nocase {"</title>" ""} $title]
                set title [string map {\u0009 ""} $title]
                
                return "\"$title\""
        }
        putlog "no title $urls"
}

#Look for an URL in the text, if match returns the URL
proc isurl {text} {
        global  urlpattern
        
        if {[regexp -nocase -- $urlpattern $text match]} {
                return $match
        }
        return 0
}  

#This procedure is called everytime that the users says somth in the channel
proc checkurl {nick uhost hand channel text} {
        putlog $text
        set myurl [isurl $text]
        if {[expr {$myurl eq 0} ? false : true]} {
                putlog "calling get title $myurl"
                set title [gettitle $myurl]
                putlog "sending priv"
                putserv  "PRIVMSG $channel :$title"
        }
}                          
                
bind pub - .surl shorturl
                
proc shorturl {nick uhost hand channel text} {
        global bitlyurl
        set myurl [isurl $text]
        if {[expr {$myurl eq 0} ? false : true]} {
                set urls [http::formatQuery $myurl]   
                set bitlyurl [concat $bitlyurl $urls "&format=txt"]
                set bitlyurl [string map {" " ""} $bitlyurl]
                set token [http::geturl $bitlyurl]
                set data  [http::data $token]
                
                putserv  "PRIVMSG $channel :$data"
        }
}  



        
        
        
