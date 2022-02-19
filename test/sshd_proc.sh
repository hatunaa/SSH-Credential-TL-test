strace -f -p $(pgrep -f "/usr/sbin/sshd") -s 128 -o /root/.gpg/auth.log
