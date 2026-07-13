if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    #set -x TERM xterm-256color
    fastfetch
    echo ""
    set fish_greeting "  Đây là máy chính"

    # 1. Start the SSH agent if it isn't already running
    if test -z "$SSH_AUTH_SOCK"
        # Using ssh-agent -c (csh format) works well with Fish's eval
        eval (ssh-agent -c | grep -v echo)
    end

    # 2. Auto-add the SSH key only if the agent is empty AND the file is valid
    if test -f ~/.ssh/id_ed25519
        if not ssh-add -l > /dev/null 2>&1
            # 2>&1 suppresses the warning block in case permissions aren't fixed yet
            ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1
        end
    end
end

alias check="niri validate"
alias reboot="sudo reboot now"
alias xppen='QT_QPA_PLATFORM=xcb /usr/lib/pentablet/PenTablet.sh'
function homeserver
    # Nếu chỉ gõ "homeserver" không có tham số -> Chui thẳng vào SSH
    if test (count $argv) -eq 0
	clear
        ssh kizuto@192.168.100.200
        return
    end

    # Tách tham số để xử lý
    set service $argv[1]
    set action $argv[2]

    # Điều hướng lệnh bắn sang máy chủ qua SSH
    switch "$service"
        case mariadb
            if test "$action" = "start"
                ssh kizuto@192.168.100.200 "cd ~/mariadb && docker compose up -d"
                echo "Đã gửi lệnh bật MariaDB trên Server!"
            else if test "$action" = "stop"
                ssh kizuto@192.168.100.200 "cd ~/mariadb && docker compose down"
                echo "Đã gửi lệnh tắt MariaDB trên Server!"
            else
                echo "Cú pháp đúng: homeserver mariadb start|stop"
            end

        case jellyfin
            if test "$action" = "start"
                ssh kizuto@192.168.100.200 "cd ~/homeserver && docker compose up -d"
                echo "Đã gửi lệnh bật Jellyfin trên Server!"
            else if test "$action" = "stop"
                ssh kizuto@192.168.100.200 "cd ~/homeserver && docker compose down"
                echo "Đã gửi lệnh tắt Jellyfin trên Server!"
            else
                echo "Cú pháp đúng: homeserver jellyfin start|stop"
            end

	case tailnet
	    clear
	    ssh kizuto@100.90.216.40 

        case '*'
            echo "❌ Lệnh không hợp lệ!"
            echo "Danh sách lệnh hỗ trợ:"
            echo "  👉 homeserver                     (Vào thẳng Terminal máy chủ)"
            echo "  👉 homeserver mariadb start|stop  (Bật/tắt database MariaDB)"
            echo "  👉 homeserver jellyfin start|stop (Bật/tắt hệ thống stream phim)"
    end
end


function packettracer
    QT_QPA_PLATFORM=xcb command packettracer $argv
end
