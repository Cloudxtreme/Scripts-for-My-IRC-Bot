
# When an user says a URL in the channel, the bot says the Title of the URL
#             Angel Gonzalez <me@angelbroz.com>

package require http
set urlpattern {(http|https)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]}

bind pubm - * isurl

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

proc isurl {nick uhost hand channel text} {
        global  urlpattern

        if {[regexp -nocase -- $urlpattern $text match]} {
                putlog "calling get title $match"
                set title [gettitle $match]
                putlog "sending priv"
                putserv  "PRIVMSG $channel :$title"
        }
}                                                                                        

